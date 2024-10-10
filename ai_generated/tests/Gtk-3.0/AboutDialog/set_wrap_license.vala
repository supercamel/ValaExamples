using Gtk;

public class Application : Window {
	public Application () {
		this.title = "About Dialog Example";
		this.window_position = WindowPosition.CENTER;
		this.destroy.connect (Gtk.main_quit);
		this.set_default_size (350, 70);

		var about_dialog = new AboutDialog();
		about_dialog.set_version("1.0");
		about_dialog.set_copyright("Copyright (C) 2023 My Company");
		about_dialog.set_translator_credits("John Doe (john@example.com)");
		about_dialog.set_license("This software is free and open source.");
		about_dialog.set_wrap_license(true);

		var button = new Button.with_label("Show About Dialog");
		this.add(button);
		button.clicked.connect(() => {
			about_dialog.run();
		});
	}

	public static int main(string[] args) {
		Gtk.init(ref args);

		var app = new Application();
		app.show_all();
		Gtk.main();
		return 0;
	}
}