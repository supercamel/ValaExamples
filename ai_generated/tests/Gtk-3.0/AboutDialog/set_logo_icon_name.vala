`public class Application : Window {
    public Application () {
        // Prepare Gtk.Window:
        this.title = "About Dialog Example";
        this.window_position = WindowPosition.CENTER;
        this.destroy.connect (Gtk.main_quit);
        this.set_default_size (350, 70);

        // Create an AboutDialog:
        var about_dialog = new AboutDialog.with_application_info (
            "About Dialog Example",
            "Example application",
            "1.0",
            "Copyright 2024"
        );

        // Show the AboutDialog:
        about_dialog.run ();
    }
}

int main (string[] args) {
    Gtk.init (ref args);
    var app = new Application ();
    app.show_all ();
    Gtk.main ();
    return 0;
}`