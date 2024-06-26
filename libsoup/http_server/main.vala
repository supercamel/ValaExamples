using Soup;

string? get_mime_type(string file_path) {
    try {
        var file = File.new_for_path(file_path);
        var file_info = file.query_info("standard::content-type", FileQueryInfoFlags.NONE);
        return file_info.get_content_type();
    } catch (Error e) {
        stderr.printf("Error determining MIME type: %s\n", e.message);
        return null;
    }
}

public class MySoupServer : Soup.Server {
	public MySoupServer(uint16 listening_port = 80) {
        listen_all(listening_port, Soup.ServerListenOptions.IPV4_ONLY);

        add_handler("/api/demo", (server, msg, path, query) => {
            if(msg.get_method() == "GET") {
                var response = "{\"demo\": \"demo\"}";
                msg.set_response("application/json", Soup.MemoryUse.COPY, response.data);
            }
            else if(msg.get_method() == "POST") {
                var body = msg.get_request_body();
                stdout.printf("Body: %s\n", (string)body.data);
                var response = "{\"demo\": \"demo\"}";
                msg.set_response("application/json", Soup.MemoryUse.COPY, response.data);
            }
            // PUT, DELETE, etc
        });

        add_handler(null, default_handler);
	}

    private static void default_handler(Soup.Server server, Soup.ServerMessage msg, string path, GLib.HashTable<string, string>? query) {
        var self = server as MySoupServer;
        stdout.printf("Serving file: " + path + "\n");
        
        if (path == "/") {
            path = "/index.html";
        }

        string current_dir = GLib.Environment.get_current_dir();
        string file_path = GLib.Path.build_filename(current_dir, "static", path);
    
        try {
            GLib.File file = GLib.File.new_for_path(file_path);
            uint8[] contents;
            if (file.load_contents(null, out contents, null)) {
                var mime_type = get_mime_type(file_path);
                msg.set_response(mime_type, Soup.MemoryUse.COPY, contents);  // Adjust MIME type as needed
            } else {
                msg.set_status(404, "File not found");
            }
        } catch (Error e) {
            msg.set_status(500, "Internal Server Error: %s".printf(e.message));  // Internal Server Error
        }
    }

	public static int main (string[] args) {
        stdout.printf("Loading gstreamer ...\n");
        stdout.flush();

        GLib.MainLoop loop = new GLib.MainLoop();

        stdout.printf("Starting ...\n");
 		var server = new MySoupServer (8888);
        stdout.printf("Server started at http://127.0.0.1:8888\n");
        stdout.flush();

        loop.run();
		return 0;
	}
}
