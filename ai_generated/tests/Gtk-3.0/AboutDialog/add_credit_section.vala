using Gtk;

public class Example : Gtk.Window {
    public Example () {
        // Prepare Gtk.Window:
        this.title = "AboutDialog Example";
        this.window_position = WindowPosition.CENTER;
        this.destroy.connect (Gtk.main_quit);
        this.set_default_size (400, 300);

        // The button:
        Gtk.Button button = new Gtk.Button.with_label ("Show About Dialog");
        this.add (button);

        button.clicked.connect (() => {
            // Emitted when the button has been activated:
            AboutDialog about_dialog = new AboutDialog ();
            about_dialog.program_name = "Example Program";
            about_dialog.version = "1.0";
            about_dialog.copyright = "2023 Example Company";
            about_dialog.comments = "This is an example program demonstrating Gtk.AboutDialog.";
            about_dialog.website = "https://example.com";
            about_dialog.website_label = "Visit Website";

            // Add a custom credit section
            string[] credits = {
                "Development",
                "John Doe <john.doe@example.com>",
                "Jane Smith <jane.smith@example.com>"
            };
            about_dialog.add_credit_section ("Credits", credits);

            about_dialog.run ();
            about_dialog.destroy ();
        });
    }

    public static int main (string[] args) {
        Gtk.init (ref args);

        Example app = new Example ();
        app.show_all ();
        Gtk.main ();
        return 0;
    }
}