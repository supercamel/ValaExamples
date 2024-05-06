// a gtk window example

public class Window : Gtk.Window {
    public Window() {
        // set title to "Hello World"
        set_title("Hello World");

        // window size to 800x600
        set_default_size(800, 600);

        // add a vbox to the window
        var vbox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        add(vbox);

        // add a button that says "Click Me"
        var button = new Gtk.Button.with_label("Click Me");

        // show a message dialog when the button is clicked
        button.clicked.connect(() => {
            Gtk.MessageDialog dialog = new Gtk.MessageDialog(this, 0, Gtk.MessageType.INFO, Gtk.ButtonsType.OK, "Hello World");
            dialog.run();
            dialog.destroy();
        });

        // add the button to the vbox
        vbox.pack_start(button, true, true, 0);

        // show the window
        show_all();
        destroy.connect(() => {
            Gtk.main_quit();
            return false;
        });

    }
}
