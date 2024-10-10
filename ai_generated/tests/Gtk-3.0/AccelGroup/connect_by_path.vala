using Gtk;

public class AcceleratorDemo : Gtk.Application {
    public AcceleratorDemo() {
        Object(application_id: "org.gtk.AcceleratorDemoApp",
               flags: ApplicationFlags.FLAGS_NONE);
    }

    protected override void activate() {
        var window = new Gtk.ApplicationWindow(this) {
            title = "Accelerator Demo",
            default_width = 300,
            default_height = 200,
            window_position = WindowPosition.CENTER
        };

        var box = new Gtk.Box(Orientation.VERTICAL, 5);
        window.add(box);

        var label = new Gtk.Label("Press Ctrl+Shift+A to trigger the accelerator.");
        box.pack_start(label, false, false, 0);

        var button = new Gtk.Button.with_label("Click Me");
        box.pack_start(button, false, false, 0);

        var accel_group = new Gtk.AccelGroup();
        window.add_accel_group(accel_group);

        // Connect button click event using the connect_by_path method
        accel_group.connect_by_path("/app/acceleratorDemo/button", (accell_group, accell_key, accell_mods, user_data) => {
            if ((uint)accell_key == (uint)Gdk.Key.a && accell_mods == (Gdk.ModifierType.CONTROL_MASK | Gdk.ModifierType.SHIFT_MASK)) {
                button.clicked();
                return true;
            }
            return false;
        });

        window.show_all();
    }

    public static int main(string[] args) {
        var app = new AcceleratorDemo();
        return app.run(args);
    }
}