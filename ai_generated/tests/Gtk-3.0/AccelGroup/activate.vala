using Gtk;

public class ExampleApp : Gtk.Application {
    public ExampleApp() {
        Object(application_id: "org.vala.exampleapp",
               flags: ApplicationFlags.FLAGS_NONE);
    }

    protected override void activate() {
        var window = new Gtk.Window();
        window.title = "AccelGroup Example";
        window.default_width = 300;
        window.default_height = 200;
        window.window_position = WindowPosition.CENTER;
        window.destroy.connect(Gtk.main_quit);

        var accel_group = new Gtk.AccelGroup();
        window.add_accel_group(accel_group);

        var button = new Gtk.Button.with_label("Click Me!");
        button.add_accelerator("clicked", accel_group, (uint)Gdk.Key.c, Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE);
        button.clicked.connect(() => {
            stdout.printf("Button clicked! (Shortcut: Ctrl+C)\n");
        });
        window.add(button);

        window.show_all();
    }

    public static int main(string[] args) {
        var app = new ExampleApp();
        return app.run(args);
    }
}