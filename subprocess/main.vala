// a gtk window
public class MainWindow : Gtk.Window {
    public MainWindow () {
        set_title("Main Window");
        set_default_size(400, 400);

        // create a button
        var button = new Gtk.Button.with_label("Click me");
        button.clicked.connect(() => {
            // show a message dialog that says "Hello World"
            var dialog = new Gtk.MessageDialog(this,
                Gtk.DialogFlags.MODAL | Gtk.DialogFlags.DESTROY_WITH_PARENT,
                Gtk.MessageType.INFO,
                Gtk.ButtonsType.OK,
                "Hello World");
            dialog.run();
            dialog.destroy();
        });

        add(button);
        show_all();
    }

}

public int main (string[] args) {

    // spawn a subprocess and pipe the output to a string
    return 0;
}