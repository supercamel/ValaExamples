
public class Recorder : Application {
    public Recorder() {
        Object(application_id: "com.vala_example.voice_recorder", flags: ApplicationFlags.HANDLES_COMMAND_LINE);
    }

    public async void record(string output_file, int recording_length) {
        // create a gstreamer pipeline that records microphone, compresses to mp3 and saves to output_file
        var pipeline = new Gst.Pipeline("recorder-pipeline");
        var source = Gst.ElementFactory.make("autoaudiosrc", "source");
        var convert = Gst.ElementFactory.make("audioconvert", "convert");
        var queue = Gst.ElementFactory.make("queue", "queue");
        var encoder = Gst.ElementFactory.make("lamemp3enc", "encoder");
        var sink = Gst.ElementFactory.make("filesink", "sink");

        sink.set("location", output_file);

        pipeline.add_many(source, convert, queue, encoder, sink);

        source.link(convert);
        convert.link(queue);
        queue.link(encoder);
        encoder.link(sink);


        // start recording
        pipeline.set_state(Gst.State.PLAYING);

        GLib.Timeout.add_seconds(recording_length, () => {
            // stop recording
            pipeline.set_state(Gst.State.NULL);
            record.callback();
            return false; // stop the timeout
        });

        yield;
    }

    public override int command_line(ApplicationCommandLine command_line) {
        string? output_file = null;
        int recording_length = 10;

        OptionEntry[] options = new OptionEntry[3];
        options[0] = { "output", 'o', 0, OptionArg.STRING, ref output_file, "The output file path", null };
        options[1] = { "length", 'l', 0, OptionArg.INT, ref recording_length, "The length of time to record for", null };
        options[2] = { null };

        // Parse command-line arguments
        string[] args = command_line.get_arguments ();
        string*[] _args = new string[args.length];
        for (int i = 0; i < args.length; i++) {
            _args[i] = args[i];
        }

        try {
            var opt_context = new OptionContext ("- a voice recording app");
            opt_context.set_help_enabled (true);
            opt_context.add_main_entries (options, null);
            unowned string[] tmp = _args;
            opt_context.parse (ref tmp);  // Parse the options
        } catch (OptionError e) {
            command_line.print ("error: %s\n", e.message);
            command_line.print ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
            return 0;
        }

        if(output_file == null) {
            command_line.print("An output file name is required\nRun with --help for more information\n");
            return 0;
        }

        hold();
        record.begin(output_file, recording_length, (obj, res) => {
            record.end(res);
            release();
        });
        return 0;
    }

	public static int main(string[] args) {
        Gst.init(ref args);
		var recorder = new Recorder();
		recorder.run(args);
		return 0;
	}
}
