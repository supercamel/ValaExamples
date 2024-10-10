using Gtk;

public class Application : Gtk.Window {
    public Application () {
        // Prepare Gtk.Window:
        this.title = "About Dialog Example";
        this.window_position = Gtk.WindowPosition.CENTER;
        this.destroy.connect (Gtk.main_quit);
        this.set_default_size (350, 70);

        // Button to open the about dialog:
        Gtk.Button button = new Gtk.Button.with_label ("Show About Dialog");
        this.add (button);

        button.clicked.connect (() => {
            Gtk.AboutDialog about_dialog = new Gtk.AboutDialog ();
            about_dialog.program_name = "Vala Gtk About Dialog Example";
            about_dialog.version = "1.0";
            about_dialog.copyright = "Copyright © 2023 Your Name";
            about_dialog.comments = "This is an example of using Gtk.AboutDialog in Vala.";
            about_dialog.website = "https://example.com";
            about_dialog.website_label = "Visit our website";

            // Set license type
            about_dialog.license_type = License.GPL_3_0;

            // Get existing license type information
            License current_license_type = about_dialog.get_license_type ();
            stdout.printf ("Current License Type: %s\n", current_license_type.to_string ());

            about_dialog.modal = true;
            about_dialog.transient_for = this;
            about_dialog.run ();
            about_dialog.destroy ();
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