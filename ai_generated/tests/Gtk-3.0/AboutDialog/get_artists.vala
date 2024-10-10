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

            // Add a custom artist section
            string[] artists = {
                "Artist 1",
                "Artist 2",
                "Artist 3"
            };
            about_dialog.add_artist_section ("Artists", artists);

            // Retrieve the artists section
            string[][] artists_sections = about_dialog.get_artists ();
            foreach (string[] section in artists_sections) {
                stdout.printf ("Section: %s\n", section[0]);
                foreach (string artist in section[1..]) {
                    stdout.printf ("  %s\n", artist);
                }
            }

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