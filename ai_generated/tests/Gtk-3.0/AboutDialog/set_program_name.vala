`public class Application : Gtk.Window {
	private AboutDialog about_dialog;

	public Application () {
		// Prepare Gtk.Window:
		this.title = "My Application";
		this.window_position = Gtk.WindowPosition.CENTER;
		this.destroy.connect (Gtk.main_quit);
		this.set_default_size (350, 70);

		// Create an AboutDialog instance:
		this.about_dialog = new AboutDialog ();

		// Set the program name:
		this.about_dialog.set_program_name ("My Application");

		// Set the version:
		this.about_dialog.set_version ("1.0");

		// Set the copyright:
		this.about_dialog.set_copyright ("Copyright 2024 My Company");

		// Set the license:
		this.about_dialog.set_license ("LGPLv2+");

		// Set the comments:
		this.about_dialog.set_comments ("This is an example application.");

		// Set the website:
		this.about_dialog.set_website ("https://example.com");

		// Show the AboutDialog:
		this.about_dialog.show_all ();
	}

	public static int main (string[] args) {
		Gtk.init (ref args);

		Application app = new Application ();
		app.show_all ();
		Gtk.main ();
		return 0;
	}
}`