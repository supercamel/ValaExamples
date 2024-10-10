using Gtk;

public class MyAccelGroupApp : Gtk.Application {
    public MyAccelGroupApp() {
        Object(application_id: "org.gtk.MyAccelGroupApp",
               flags: ApplicationFlags.FLAGS_NONE);
    }

    protected override void activate() {
        var window = new Gtk.ApplicationWindow(this) {
            title = "AccelGroup Example",
            default_width = 300,
            default_height = 200,
            window_position = WindowPosition.CENTER
        };

        var button = new Gtk.Button.with_label("Click Me!");
        window.add(button);

        var accel_group = new Gtk.AccelGroup();
        window.add_accel_group(accel_group);

        var accel_key = Gdk.Key.c;
        var accel_mods = Gdk.ModifierType.CONTROL_MASK | Gdk.ModifierType.SHIFT_MASK;
        var accel_flags = Gtk.AccelFlags.VISIBLE;

        accel_group.connect(accel_key, accel_mods, accel_flags, () => {
            button.clicked();
            return false;
        });

        button.add_accelerator("clicked", accel_group, accel_key, accel_mods, accel_flags);

        window.show_all();
    }

    public static int main(string[] args) {
        var app = new MyAccelGroupApp();
        return app.run(args);
    }
}