using Gtk;

public class MyApplication : Application {
    public MyApplication () {
        // Prepare Gtk.Application:
        this.application_id = "com.example.MyApplication";
        this.flags = ApplicationFlags.FLAGS_NONE;
        this.activate.connect (() => {
            var about_dialog = new AboutDialog ();
            about_dialog.program_name = "My Application";
            about_dialog.version = "1.0";
            about_dialog.copyright = "Copyright © 2023 Example Company";
            about_dialog.comments = "This is a demonstration of Gtk.AboutDialog.";
            about_dialog.website = "https://example.com";
            about_dialog.website_label = "Visit our website";
            about_dialog.authors = ["John Doe", "Jane Smith"];
            about_dialog.documenters = ["Doe, John", "Smith, Jane"];
            about_dialog.translator_credits = about_dialog.get_translator_credits ();
            about_dialog.license_type = License.GPL_3_0;
            about_dialog.modal = true;
            about_dialog.destroy_with_parent = true;
            about_dialog.show_all ();
        });
    }

    public static int main (string[] args) {
        Gtk.init (ref args);

        MyApplication app = new MyApplication ();
        return app.run (args);
    }
}