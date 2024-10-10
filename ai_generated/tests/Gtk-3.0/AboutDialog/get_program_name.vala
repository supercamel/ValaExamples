using Gtk;

public class Application : Gtk.Window {
    public Application () {
        // Prepare Gtk.Window:
        this.title = "About Dialog Example";
        this.window_position = Gtk.WindowPosition.CENTER;
        this.destroy.connect (Gtk.main_quit);
        this.set_default_size (350, 70);

        // Create a button to show the about dialog
        Gtk.Button button = new Gtk.Button.with_label ("Show About Dialog");
        this.add (button);

        // Connect the button's clicked signal to the show_about_dialog function
        button.clicked.connect (() => {
            show_about_dialog ();
        });
    }

    private void show_about_dialog () {
        // Create an AboutDialog
        Gtk.AboutDialog about_dialog = new Gtk.AboutDialog ();

        // Set properties for the AboutDialog
        about_dialog.program_name = "My Application";
        about_dialog.version = "1.0";
        about_dialog.copyright = "Copyright © 2023 My Company";
        about_dialog.comments = "This is a simple application demonstrating Gtk.AboutDialog.";
        about_dialog.authors = ["John Doe", "Jane Smith"];
        about_dialog.translator_credits = "Translated by Jane Doe";

        // Set the logo icon name using get_logo_icon_name
        string[] logo_icon_names = this.get_logo_icon_name ();
        if (logo_icon_names != null && logo_icon_names.length > 0) {
            about_dialog.logo_icon_name = logo_icon_names[0];
        }

        // Show the AboutDialog
        about_dialog.run ();
        about_dialog.destroy ();
    }

    public static int main (string[] args) {
        Gtk.init (ref args);

        Application app = new Application ();
        app.show_all ();
        Gtk.main ();
        return 0;
    }
}