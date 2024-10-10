using Gtk;

public class MainApplication : Gtk.Application {
    public MainApplication() {
        Object(application_id: "org.gtk.AccelGroupDemoApp",
               flags: ApplicationFlags.FLAGS_NONE);
    }

    protected override void activate() {
        var window = new Window();
        window.title = "AccelGroup Demo";
        window.default_width = 300;
        window.default_height = 200;
        window.window_position = WindowPosition.CENTER;
        window.destroy.connect(Gtk.main_quit);

        var vbox = new Box(Orientation.VERTICAL, 5);
        window.add(vbox);

        var label = new Label("Press Ctrl+Z to trigger the accelerator.");
        vbox.pack_start(label, false, false, 0);

        var button = new Button.with_label("Click Me");
        vbox.pack_start(button, false, false, 0);

        var accel_group = new AccelGroup();
        window.add_accel_group(accel_group);

        button.add_accelerator("clicked", accel_group, (uint)Gdk.Key.z, Gdk.ModifierType.CONTROL_MASK, AccelFlags.VISIBLE);

        button.clicked.connect(() => {
            label.label = "Button clicked!";
        });

        accel_group.connect((uint)Gdk.Key.z, Gdk.ModifierType.CONTROL_MASK, AccelFlags.VISIBLE, () => {
            label.label = "Accelerator triggered!";
            return false;
        });

        window.show_all();
    }

    public static int main(string[] args) {
        var app = new MainApplication();
        return app.run(args);
    }
}