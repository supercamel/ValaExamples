
#!/usr/bin/env python3

import os
import xml.etree.ElementTree as ET
import requests
import json
import subprocess
import re
from inference import tryMessages

api_data = []

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


def try_build_code(pkg, code):
    # write 'code' to the file 'tests/main.vala', replacing the existing code
    with open("tests/main.vala", "w") as f:
        f.write(code)
    result = subprocess.run(["valac", f"--pkg={pkg}", "--pkg=gtk4", "--pkg=gee-0.8", "--pkg=gio-2.0", "--pkg=glib-2.0", "tests/main.vala"], text=True, capture_output=True)
    return result.returncode, result.stdout + result.stderr

def extract_first_vala_code_block(response):
    # Find the starting point of the first Vala code block
    start_index = response.find("```vala")
    
    if start_index == -1:
        # If no Vala code block is found
        return None

    # Move the index to the end of '```vala' to start after the opening marker
    start_index += len("```vala")

    # Find the next closing code block marker
    end_index = response.find("```", start_index)

    if end_index == -1:
        # If no closing marker is found
        return None

    # Extract and clean the code block
    code_block = response[start_index:end_index].strip()
    return code_block

def extract_mentioned_libraries(error_message):
    # Use regex to find all occurrences of "does not exist in the context of `xyz`"
    matches = re.findall(r"does not exist in the context of `([a-zA-Z0-9_.]+)'", error_message)
    matches.extend(re.findall(r"extra arguments for ` ([a-zA-z0-9_.])'", error_message))
    return matches

def find_documentation(s):
    global api_data
    if "." in s:
        try:
            library, entity = s.split(".")
            for library in api_data:
                if library['library'] == library:
                    for entity in library['entities']:
                        if entity['name'] == entity:
                            documentation = entity['documentation']
                            documentation += "Methods:\n"
                            for method in entity['methods']:
                                documentation += f"\n\n{method['name']}:\n{method['documentation']}"
                            documentation += "Properties:\n"
                            for prop in entity['properties']:
                                documentation += f"\n\n{prop['name']}:\n{prop['documentation']}"
                            return documentation
        except:
            return ""
    
    return "" 

msgs = []

base_user_prompt = "Write an example useage of the Gtk.Button from Gtk+-3.0 API in the Vala programming language."
base_reply = """Certainly! Below is a complete example of a Vala program that demonstrates how to use a Gtk.Button.
```vala
public class Application : Gtk.Window {
	private int click_counter = 0;

	public Application () {
		// Prepare Gtk.Window:
		this.title = "My Gtk.Button";
		this.window_position = Gtk.WindowPosition.CENTER;
		this.destroy.connect (Gtk.main_quit);
		this.set_default_size (350, 70);

		// The button:
		Gtk.Button button = new Gtk.Button.with_label ("Click me (0)");
		this.add (button);

		button.clicked.connect (() => {
			// Emitted when the button has been activated:
			button.label = "Click me (%d)".printf (++this.click_counter);
		});
	}

	public static int main (string[] args) {
		Gtk.init (ref args);

		Application app = new Application ();
		app.show_all ();
		Gtk.main ();
		return 0;
	}
}
```
"""
msgs.append({"role": "user", "content": base_user_prompt })
msgs.append({"role": "assistant", "content": base_reply })

def write_method_example(pkg, namespace, version, entity, method_name, replace_existing = False):
    global msgs
    entity_name = entity['name']

    if("Abstract" in entity_name):
        return
    if("reserved" in method_name):
        return

    # first check if the code already exists
    if(replace_existing == False):
        if os.path.exists(f"tests/{namespace}-{version}/{entity_name}/{method_name}.vala"):
            return

    msgs = []
    msgs.append({"role": "user", "content": base_user_prompt })
    msgs.append({"role": "assistant", "content": base_reply })

   
    # check if example.vala exists in the directory
    if os.path.exists(f"tests/{namespace}-{version}/{entity_name}/example.vala"):
        with open(f"tests/{namespace}-{version}/{entity_name}/example.vala", "r") as file:
            code = file.read()
        
        # Append the code to the messages
        msgs.append({"role": "user", "content": f"Write an application in Vala showing use of the {entity_name} {entity['type']} in the {namespace}-{version} API."})
        msgs.append({"role": "assistant", "content": "Certainly! Here is the code showing usage as per your request.\n```vala\n" + code + "\n```\n"})
    
    prompt = f"Write an example usage of the {method_name} method from the {entity_name} {entity['type']} in the {namespace}-{version} API."
    prompt += f"The code must be in the Vala programming language and should demonstrate how to use the {entity['type']} in a simple program."
    prompt += "Remember, Vala arrays can be declared like this: int a[] = {1,2,3}\nVala arrays can be passes as parameters like this: foo({1,2,3}), NOT like this: foo([1,2,3])\n"
    prompt += "In Vala, functions don't take named parameters, so code like this: new Button(label: \"Show About Dialog\"); is wrong. Instead, use the appropriate constructor. E.g. new Button.with_label(\"Show About Dialog\");"
    prompt += "Never use curly braces to initialise objects. E.g. Window win = new Window { }; is a syntax error. Instead use the object constructor method with appropriate parameters. E.g. var win = new Window();\n"
    prompt += "Don't use additional libraries unless required.\n"
    prompt += "The program must be a complete example that can be compiled and run successfully. Format the code within vala code blocks with backticks."

    # append the prompt to the messages list
    msgs.append({ "role": "user", "content": prompt })

    last_response = tryMessages(msgs)
    msgs.append({"role": "assistant", "content": last_response} )

    # extract the code block from the response
    code_block = extract_first_vala_code_block(last_response)
    if(code_block is None):
        write_method_example(pkg, namespace, version, entity, method_name, True)
        return

    # try to compile the code with valac, including the necessary dependencies, and pipe the output and return code
    for i in range(3):
        return_code, output = try_build_code(pkg, code_block)

        # save the code to namespace/version/entity/method_name.vala
        # create the directory first
        os.makedirs(f"tests/{namespace}-{version}/{entity_name}", exist_ok=True)
        with open(f"tests/{namespace}-{version}/{entity_name}/{method_name}.vala", "w") as f:
            f.write(code_block)
        
        if(return_code == 0):
            print("Successfully compiled code.")
            # now check that the code contains the method 
            if(method_name not in code_block):
                write_method_example(pkg, namespace, version, entity, method_name, True)
            return
        else:
            print(f"Error compiling code for {method_name} in {entity_name}: {output}")
            mentioned_libraries = extract_mentioned_libraries(output)
            additional_docs = ""

            for s in mentioned_libraries:
                additional_docs += find_documentation(s) 

            prompt = f"An error occurred while compiling this Vala code. Here is the compiler output:\n"
            prompt += output
            if(additional_docs != "" and additional_docs != None):
                prompt += "Here is some documentation for the libraries mentioned in the error message:\n"
                prompt += additional_docs
            if "correctly initialized with curly braces" in last_response:
                prompt += "Note that objects are not normally initialised with curly braces in Vala.\n"
            if len(re.findall(r" = new ([a-zA-Z]) {", output)) > 0:
                prompt += "Note that objects are not normally initialised with curly braces in Vala.\n"
            prompt += "Remember, Vala arrays can be declared like this: int a[] = {1,2,3}\nVala arrays can be passes as parameters like this: foo({1,2,3}), NOT like this: foo([1,2,3])\n"
            prompt += "Arrays passed incorrectly with square brackets will cause the error 'syntax error, expected identifier'\n"
            prompt += "In Vala, functions don't take named parameters, so code like this: new Button(label: \"Show About Dialog\"); is wrong. Instead, use the appropriate constructor. E.g. new Button.with_label(\"Show About Dialog\");"
            prompt += "\nWrite the corrected code, ensuring the new code is formatted within vala code blocks with backticks. E.g. \n```vala\n//code goes here\n```\n"

            msgs.append({"role": "user", "content": prompt} )

            last_response = tryMessages(msgs)
            msgs.append({"role": "assistant", "content": last_response} )


            # write msgs to msg log file
            with open("messages.txt", "w") as f:
                for msg in msgs:
                    if(msg["role"] == "user"):
                        f.write(f"\nUser: {msg['content']}\n")
                        f.write("~~~~~~~~~~~~~~~~~~")
                    else:
                        f.write(f"\nAssistant: {msg['content']}\n" )
                        f.write("~~~~~~~~~~~~~~~~~~")
            

            # extract the code block from the response
            code_block = extract_first_vala_code_block(last_response)

            if(code_block is None):
                write_method_example(pkg, namespace, version, entity, method_name, True)

            print("Code Block: ")
            print(code_block)

    write_method_example(pkg, namespace, version, entity, method_name, True)


# Main execution
def main():
    global api_data
    # Specify the namespaces and versions
    namespaces_versions = [
        ('Gee', '0.8', 'gee-0.8'),
        ('Gtk', '4.0', 'gtk4'),
        ('Gdk', '3.0', 'gdk-3.0'),
        ('GLib', '2.0', 'glib-2.0'),
        ("Gio", "2.0", "gio-2.0"),
        ('cairo', '1.0', 'cairo'),
        ('Pango', '1.0', "pango"),
    ]

    # Process each namespace and version
    for namespace, version, pkg in namespaces_versions:
        # Construct the GIR file path
        gir_file = f'/usr/share/gir-1.0/{namespace}-{version}.gir'

        try:
            # Initialize the parser
            parser = GIRParser(gir_file, namespace, version)

            # Parse the GIR file
            print(f"Parsing GIR file for {namespace}-{version}...")
            api_data.append({ "library": namespace, "version": version, "entities": parser.parse() })
            print(f"Parsed {len(api_data)} API entities for {namespace}-{version}.")

        except FileNotFoundError as e:
            print(e)


    for namespace, version, pkg in namespaces_versions:
        # Write method examples
        for library in api_data:
            for entity in library['entities']:
                if entity['type'] == 'class':
                    for method in entity['methods']:
                        write_method_example(pkg, namespace, version, entity, method['name'])

if __name__ == '__main__':
    main()