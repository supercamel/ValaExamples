
// a gtk window
public class Window : Gtk.Window {
    public Window () {
        set_title ("My Video Player");

        set_default_size (640, 480);
        set_position (Gtk.WindowPosition.CENTER);

        var vbox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        add (vbox);

        var hbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        vbox.pack_start (hbox, true, true, 0);

        var label = new Gtk.Label("Select a file to play:");
        var button = new Gtk.FileChooserButton("Open", Gtk.FileChooserAction.OPEN);

        button.selection_changed.connect (() => {
            var file = button.get_uri();
            stdout.printf ("File selected: %s\n", file);
            playbin.set_property ("uri", file);
            playbin.set_state(Gst.State.PAUSED);
        });

        hbox.pack_start (label, true, true, 0);
        hbox.pack_start (button, true, true, 0);

        playbin = Gst.ElementFactory.make ("playbin", "playbin");
        playbin.set("force_aspect_ratio", false);
        var gtksink = Gst.ElementFactory.make ("gtksink", "gtksink");
        playbin.set("video-sink", gtksink);

        gtksink.set("force_aspect_ratio", false);
        gtksink.get("widget", out video_widget);

        assert (video_widget != null);
        assert (video_widget is Gtk.DrawingArea);

        video_widget.set_size_request(640, 480);
        video_widget.hexpand = true;
        video_widget.vexpand = true;

        vbox.pack_start(video_widget);

        var bus = playbin.get_bus ();
        bus.add_watch (GLib.Priority.DEFAULT, watch_cb);


        destroy.connect (() => {
            Gtk.main_quit ();
            playbin.set_state (Gst.State.NULL);
        });
    }

    private bool watch_cb (Gst.Bus bus, Gst.Message msg) {
        switch (msg.type) {
            case Gst.MessageType.ASYNC_DONE:
                playbin.set_state (Gst.State.PLAYING);
                break;
        }
        return true;
    }

    Gst.Element playbin;
    Gtk.Widget video_widget;

}

public int main(string[] args) {
    Gst.init (ref args);
    Gtk.init (ref args);
    Window window = new Window ();
    window.show_all ();

    Gtk.main ();
    return 0;
}