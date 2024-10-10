using Gtk;

public class Application : Gtk.Window {
    private void show_about_dialog() {
        AboutDialog about_dialog = new AboutDialog();
        about_dialog.program_name = "My Gtk Application";
        about_dialog.version = "1.0";
        about_dialog.copyright = "(c) 2023 My Company";
        about_dialog.website = "https://www.example.com";
        about_dialog.website_label = "Visit our website";

        // Set the license text for the about dialog
        about_dialog.set_license("MIT License\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.");

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