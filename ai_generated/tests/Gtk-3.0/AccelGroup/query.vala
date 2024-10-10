using Gtk;

public class AccelGroupDemoApp : Gtk.Application {
    public AccelGroupDemoApp() {
        Object(application_id: "org.gtk.AccelGroupDemoApp",
               flags: ApplicationFlags.FLAGS_NONE);
    }

    protected override void activate() {
        var window = new ApplicationWindow(this) {
            title = "AccelGroup Demo",
            default_width = 500,
            default_height = 350,
            window_position = WindowPosition.CENTER
        };

        var accel_group = new AccelGroup();
        window.add_accel_group(accel_group);

        var vbox = new Box(Orientation.VERTICAL, 5);
        vbox.margin_top = 10;
        vbox.margin_bottom = 10;
        vbox.margin_start = 10;
        vbox.margin_end = 10;
        window.add(vbox);

        var info_label = new Label("Press Ctrl+Shift+A to trigger the accelerator.");
        vbox.pack_start(info_label, false, false, 0);

        var button = new Button.with_label("Click me or press Ctrl+Shift+A!");
        button.clicked.connect(() => {
            info_label.label = "Button clicked! (Shortcut: Ctrl+Shift+A)";
        });
        vbox.pack_start(button, false, false, 0);

        button.add_accelerator("clicked", accel_group, (uint)Gdk.Key.a, Gdk.ModifierType.CONTROL_MASK | Gdk.ModifierType.SHIFT_MASK, AccelFlags.VISIBLE);

        accel_group.connect((uint)Gdk.Key.a, Gdk.ModifierType.CONTROL_MASK | Gdk.ModifierType.SHIFT_MASK, AccelFlags.VISIBLE, () => {
            info_label.label = "Accelerator triggered: Ctrl+Shift+A!";
            return false;
        });

        window.show_all();
    }

    public static int main(string[] args) {
        var app = new AccelGroupDemoApp();
        return app.run(args);
    }
}