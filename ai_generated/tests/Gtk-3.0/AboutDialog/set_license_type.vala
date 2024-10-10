using Gtk;

public class Application : Gtk.Window {
    private void show_about_dialog() {
        AboutDialog about_dialog = new AboutDialog();
        about_dialog.program_name = "My Gtk Application";
        about_dialog.version = "1.0";
        about_dialog.copyright = "(c) 2023 My Company";
        about_dialog.website = "https://www.example.com";
        about_dialog.website_label = "Visit our website";

        // Set the license type for the about dialog
        about_dialog.set_license_type(License.MIT_X11);

        // Connect the response signal to close the dialog
        about_dialog.response.connect((dialog, response_id) => {
            dialog.destroy();
        });

        about_dialog.show_all();
    }

    public Application() {
        this.title = "Main Window";
        this.window_position = WindowPosition.CENTER;
        this.destroy.connect(Gtk.main_quit);
        this.set_default_size(300, 200);

        // Create a button to show the about dialog
        Gtk.Button button = new Gtk.Button.with_label("Show About Dialog");
        this.add(button);

        // Connect the button's clicked signal to the show_about_dialog method
        button.clicked.connect(show_about_dialog);
    }

    public static int main(string[] args) {
        Gtk.init(ref args);

        Application app = new Application();
        app.show_all();
        Gtk.main();

        return 0;
    }
}