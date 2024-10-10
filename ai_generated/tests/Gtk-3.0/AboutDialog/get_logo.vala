using Gtk;
using GdkPixbuf;

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

            // Set logo
            GdkPixbuf.Pixbuf logo = GdkPixbuf.Pixbuf.new_from_file ("path/to/your/logo.png");
            about_dialog.logo = logo;

            // Get existing logo
            GdkPixbuf.Pixbuf current_logo = about_dialog.get_logo ();
            if (current_logo != null) {
                stdout.printf ("Current Logo: %s\n", current_logo.get_filename ());
            } else {
                stdout.printf ("No logo set.\n");
            }

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