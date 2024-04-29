// Define the VGet class which inherits from the Application class
public class VGet : Application {
    // Constructor for VGet, sets the application ID and handles command line
    public VGet() {
        Object(application_id: "com.vala_example.vget", flags: ApplicationFlags.HANDLES_COMMAND_LINE);
    }

    // Asynchronous method to pause execution, useful for throttling updates
    public async void nap (uint interval, int priority = GLib.Priority.DEFAULT) {
        GLib.Timeout.add (interval, () => {
            nap.callback ();  // Ends the current asynchronous wait
            return false;     // Return false to stop the timeout from repeating
          }, priority);
        yield;  // Yield control until the timeout callback is called
      }

    // Asynchronous method to download a file from a given URI
    public async bool download_file(ApplicationCommandLine command_line, string uri, string output_file) {
        // Create a new HTTP session
        var session = new Soup.Session();

        // Create a new HTTP GET request
        var message = new Soup.Message("GET", uri);
        message.flags = Soup.MessageFlags.COLLECT_METRICS; // Collect metrics to report download progress

        // Send the request asynchronously and retrieve the response stream
        var stream = yield session.send_async(message, 0, null);

        // Setup the output file, deleting existing one if necessary
        var file = File.new_for_path(output_file);
        if(file.query_exists()) {
            yield file.delete_async(); // Asynchronously delete the file if it exists
        }
        var out_stream = file.create(FileCreateFlags.REPLACE_DESTINATION); // Create or replace the output file

        bool downloading = true;
        // Asynchronously splice the input stream to the output file
        out_stream.splice_async.begin(stream, 
            GLib.OutputStreamSpliceFlags.CLOSE_TARGET | GLib.OutputStreamSpliceFlags.CLOSE_SOURCE, 
            Priority.DEFAULT, null, 
            (obj, res) => {
                out_stream.splice_async.end(res); // End splicing upon completion
                downloading = false; // Update flag when download is complete
        });

        // Retrieve total size of the download for progress reporting
        var bytes_total = message.get_response_headers().get_content_length();
        while(downloading) {
            // Fetch metrics to update progress
            var metrics = message.get_metrics();
            if(metrics != null) {
                var bytes_received = metrics.get_response_body_bytes_received();
                command_line.print("Downloaded %lu of %lu bytes.\n", (ulong)bytes_received, (ulong)bytes_total);
            }

            yield nap(1000); // Pause for 1 second between progress updates
        }

        command_line.print("Download completed successfully.\n");
        return true;  // Return true when the download completes successfully
    }

    // Runs the application logic
    public override int command_line(ApplicationCommandLine command_line) {
        // Initialize variables for command-line options
        string? uri = null;
        string? output_file = null;

        // Set up command-line options
        OptionEntry[] options = new OptionEntry[3];
        options[0] = { "uri", 'd', 0, OptionArg.STRING, ref uri, "A URI to download", null };
        options[1] = { "output", 'o', 0, OptionArg.STRING, ref output_file, "The output file", null };
        options[2] = { null };

        // Parse command-line arguments
        string[] args = command_line.get_arguments ();
        string*[] _args = new string[args.length];
        for (int i = 0; i < args.length; i++) {
            _args[i] = args[i];
        }

        try {
            var opt_context = new OptionContext ("- VGet, a little bit like wget except written in Vala");
            opt_context.set_help_enabled (true);
            opt_context.add_main_entries (options, null);
            unowned string[] tmp = _args;
            opt_context.parse (ref tmp);  // Parse the options
        } catch (OptionError e) {
            command_line.print ("error: %s\n", e.message);
            command_line.print ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
            return 0;
        }

        // Check for required URI input
        if(uri == null) {
            command_line.print("A valid URI is required. Run with --help for more information.\n");
            return 0;
        }

        // Determine the output file name if not provided
        if(output_file == null) {
            string[] uri_split = uri.split("/");
            if(uri_split.length > 0) {
                output_file = uri_split[uri_split.length - 1];
                if(output_file.length == 0) {
                    output_file = "out";
                }
            }
        }

        // Keep the application instance alive while it's running
        hold();
        // Start the download asynchronously
        download_file.begin(command_line, uri, output_file, (obj, res) => {
            download_file.end(res);
            command_line.print("Download complete.\n");
            release(); // Release the application instance once done
        });
        return 0;
    }

    // Main entry point for the application
	public static int main(string[] args) {
		VGet vget = new VGet();  // Create a new instance of VGet
		int status = vget.run(args);  // Run the application with the provided arguments
		return status;  // Return the application status
	}
}
