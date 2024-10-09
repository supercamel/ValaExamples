
#!/usr/bin/env python3

import os
import xml.etree.ElementTree as ET
import requests
import json
import subprocess
from inference import tryMessages

class GIRParser:
    """
    Parses GIR (GObject Introspection Repository) XML files to extract API information.
    """

    NAMESPACES = {
        'gi': 'http://www.gtk.org/introspection/core/1.0',
        'c': 'http://www.gtk.org/introspection/c/1.0'
    }

    def __init__(self, gir_file, namespace, version):
        self.gir_file = gir_file
        self.namespace = namespace
        self.version = version

        if not os.path.exists(self.gir_file):
            raise FileNotFoundError(f"GIR file not found: {self.gir_file}")

        self.tree = ET.parse(self.gir_file)
        self.root = self.tree.getroot()

    def parse(self):
        """
        Parses the GIR file and returns a list of API entities.
        """
        api_data = []
        api_data.extend(self._parse_functions())
        api_data.extend(self._parse_classes())
        api_data.extend(self._parse_enums())
        return api_data

    def _parse_functions(self):
        functions = [self._parse_function(func) for func in self.root.findall('.//gi:function', self.NAMESPACES)]
        return functions

    def _parse_function(self, func):
        return {
            'type': 'function',
            'name': func.get('name'),
            'c_identifier': func.get(f'{{{self.NAMESPACES["c"]}}}identifier'),
            'return_type': self._get_type(func.find('gi:return-value/gi:type', self.NAMESPACES)),
            'parameters': self._get_parameters(func.find('gi:parameters', self.NAMESPACES)),
            'description': self._get_description(func),
            'namespace': self.namespace,
            'version': self.version
        }

    def _parse_classes(self):
        classes = [self._parse_class(class_elem) for class_elem in self.root.findall('.//gi:class', self.NAMESPACES)]
        return classes

    def _parse_class(self, class_elem):
        return {
            'type': 'class',
            'name': class_elem.get('name'),
            'inherits_from': class_elem.get('parent'),
            'implements': [iface.get('name') for iface in class_elem.findall('gi:implements', self.NAMESPACES)],
            'description': self._get_description(class_elem),
            'properties': self._get_properties(class_elem),
            'methods': self._get_methods(class_elem),
            'namespace': self.namespace,
            'version': self.version
        }

    def _parse_enums(self):
        enums = [self._parse_enum(enum_elem) for enum_elem in self.root.findall('.//gi:enumeration', self.NAMESPACES)]
        return enums

    def _parse_enum(self, enum_elem):
        return {
            'type': 'enum',
            'name': enum_elem.get('name'),
            'values': [
                {
                    'name': member.get('name'),
                    'description': self._get_description(member)
                } for member in enum_elem.findall('gi:member', self.NAMESPACES)
            ],
            'description': self._get_description(enum_elem),
            'namespace': self.namespace,
            'version': self.version
        }

    def _get_parameters(self, params_elem):
        if params_elem is None:
            return []
        return [
            {
                'name': param.get('name'),
                'type': self._get_type(param.find('gi:type', self.NAMESPACES))
            } for param in params_elem.findall('gi:parameter', self.NAMESPACES)
        ]

    def _get_properties(self, class_elem):
        return [
            {
                'name': prop.get('name'),
                'type': self._get_type(prop.find('gi:type', self.NAMESPACES)),
                'description': self._get_description(prop),
                'access': self._get_property_access(prop)
            } for prop in class_elem.findall('gi:property', self.NAMESPACES)
        ]

    def _get_methods(self, class_elem):
        return [
            {
                'name': method.get('name'),
                'return_type': self._get_type(method.find('gi:return-value/gi:type', self.NAMESPACES)),
                'parameters': self._get_parameters(method.find('gi:parameters', self.NAMESPACES)),
                'description': self._get_description(method)
            } for method in class_elem.findall('gi:method', self.NAMESPACES)
        ]

    def _get_type(self, type_elem):
        if type_elem is None:
            return 'void'
        return type_elem.get('name') or type_elem.get('c:type') or 'unknown'

    def _get_description(self, elem):
        doc = elem.find('gi:doc', self.NAMESPACES)
        return doc.text.strip() if doc is not None else ''

    def _get_property_access(self, prop):
        readable = prop.get('readable') == '1'
        writable = prop.get('writable') == '1'
        if readable and writable:
            return 'readwrite'
        elif readable:
            return 'readonly'
        elif writable:
            return 'writeonly'
        return 'none'


class DatabaseClient:
    """
    Encapsulates database operations. Designed to be easily replaceable for different backends.
    """

    def __init__(self, host='localhost', port=8080):
        self.host = host
        self.port = port
        self.base_url = f"http://{self.host}:{self.port}/"

        # drop the api_data collection so we can start fresh
        command = {
            "cmd": "dropCollection",
            "collection": "api_data"
        }
        response = requests.post(self.base_url, json=command)
        if response.status_code != 200:
            raise Exception(f"Failed to drop collection: {response.text}")

    def insert_entity(self, entity):
        command = {
            "cmd": "append",
            "collection": "api_data",
            "document": json.dumps(entity)
        }
        response = requests.post(self.base_url, json=command)
        if response.status_code != 200:
            raise Exception(f"Failed to insert entity: {response.text}")
    
    def update_entity(self, entity):
        command = {
            "cmd": "update",
            "collection": "api_data",
            "query": {
                "$and": [
                    {"name": entity['name']},
                    {"namespace": entity['namespace']},
                    {"version": entity['version']}
                ]
            },
            "update": {
                "$set": entity
            }
        }
        response = requests.post(self.base_url, json=command)
        if response.status_code != 200:
            raise Exception(f"Failed to update entity: {response.text}")

    def find_entity(self, namespace, version, entity_name):
        command = {
            "cmd": "findOne",
            "collection": "api_data",
            "query": {
                "$and": [
                    {"name": entity_name},
                    {"namespace": namespace},
                    {"version": version}
                ]
            }
        }
        response = requests.post(self.base_url, json=command)
        if response.status_code != 200:
            raise Exception(f"Failed to find entity: {response.text}")
        return response.json()

    def insert_entities(self, entities):
        for entity in entities:
            self.insert_entity(entity)

    def close(self):
        pass

def save_code_to_db(db_client, namespace, version, entity_name, method_name, code):
    entity = db_client.find_entity(namespace, version, entity_name)
    entity['examples'][method_name] = code
    db_client.update_entity(entity)

def try_build_code(pkg, code):
    with open("tests/main.vala", "w") as f:
        f.write(code)
    result = subprocess.run(["valac", f"--pkg={pkg}", "--pkg=gio-2.0", "--pkg=glib-2.0", "tests/main.vala"], text=True, capture_output=True)
    return result.returncode, result.stdout + result.stderr

def write_method_example(db_client, pkg, namespace, version, entity, method_name):
    entity_name = entity['name']
    prompt = f"Write an example usage of the {method_name} method from the {entity_name} {entity['type']} in the {namespace}-{version} API."
    prompt += f"The code must be in the Vala programming language and should demonstrate how to use the {entity['type']} in a simple program."
    prompt += "The program must be a complete example that can be compiled and run successfully. Enclose the code within ```vala and ``` tags."

    msgs = [
        { "role": "system", "content": "You are a helpful AI assistant." },
        { "role": "user", "content": prompt }
    ]

    response = tryMessages(msgs)

    # extract the code block from the response
    code_block = response.split("```vala")[1].split("```")[0].strip()

    # write the code block to tests/main.vala
    with open("tests/main.vala", "w") as f:
        f.write(code_block)
    
    # try to compile the code with valac, including the necessary dependencies, and pipe the output and return code
    for i in range(10):
        return_code, output = try_build_code(pkg, code_block)
        print(f"Return code: {return_code}")
        print(f"Output: {output}")

        # if the code compiles successfully, save it to the database
        if(return_code == 0):
            save_code_to_db(db_client, namespace, version, entity_name, method_name, code_block)
            print("Successfully compiled code.")
            return
        else:
            print(f"Error compiling code for {method_name} in {entity_name}: {output}")

            prompt = f"An error occurred while compiling the code for the {method_name} method from the {entity_name} {entity['type']} in the {namespace}-{version} API."
            prompt += "The error message is as follows:"
            prompt += output
            prompt += "Please correct the code and try again."
            prompt += f"The code must showcase use of the {entity_name} {entity['type']} {method_name} method and be in the Vala programming language. Enclose the code within ```vala and ``` tags."

            msgs = [
                { "role": "system", "content": "You are a helpful AI assistant." },
                { "role": "user", "content": prompt }
            ]

            response = tryMessages(msgs)

            print(response)

            # extract the code block from the response
            code_block = response.split("```vala")[1].split("```")[0].strip()

            # write the code block to tests/main.vala
            with open("tests/main.vala", "w") as f:
                f.write(code_block)





# Main execution
def main():
    # Specify the namespaces and versions
    namespaces_versions = [
        ('Gtk', '3.0', 'gtk+-3.0'),
        ('Gdk', '3.0', 'gdk-3.0'),
        ('Gtk', '4.0', 'gtk4'),
        ('GLib', '2.0', 'glib-2.0'),
        ("Gio", "2.0", "gio-2.0"),
        ('cairo', '1.0', 'cairo'),
        ('Pango', '1.0', "pango"),
    ]

    # Initialize the database client
    db_client = DatabaseClient()

    # Process each namespace and version
    for namespace, version, pkg in namespaces_versions:
        # Construct the GIR file path
        gir_file = f'/usr/share/gir-1.0/{namespace}-{version}.gir'

        try:
            # Initialize the parser
            parser = GIRParser(gir_file, namespace, version)

            # Parse the GIR file
            print(f"Parsing GIR file for {namespace}-{version}...")
            api_data = parser.parse()
            print(f"Parsed {len(api_data)} API entities for {namespace}-{version}.")

            # Insert data into the database
            print(f"Inserting data for {namespace}-{version} into the database...")
            db_client.insert_entities(api_data)
            print(f"Data insertion complete for {namespace}-{version}.")

            # Write method examples
            for entity in api_data:
                if entity['type'] == 'class':
                    for method in entity['methods']:
                        write_method_example(db_client, pkg, namespace, version, entity, method['name'])
                        exit()

        except FileNotFoundError as e:
            print(e)

    # Close the database connection
    db_client.close()
    print("Database connection closed.")


if __name__ == '__main__':
    main()