using Gtk;

public class AccelGroupExample : Gtk.Application {
    public AccelGroupExample() {
        Object(application_id: "org.gtk.AccelGroupExample", flags: ApplicationFlags.FLAGS_NONE);
    }

    protected override void activate() {
        var window = new Gtk.ApplicationWindow(this) {
            title = "AccelGroup Example",
            default_width = 300,
            default_height = 200,
            window_position = WindowPosition.CENTER
        };

        var accel_group = new Gtk.AccelGroup();
        window.add_accel_group(accel_group);

        var button = new Gtk.Button.with_label("Click Me");
        accel_group.connect((uint)Gdk.Key.c, Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE, () => {
            button.activate();
            return false;
        });

        button.clicked.connect(() => {
            stdout.printf("Button clicked!\n");
        });

        window.add(button);
        window.show_all();
    }

    public static int main(string[] args) {
        var app = new AccelGroupExample();
        return app.run(args);
    }
}