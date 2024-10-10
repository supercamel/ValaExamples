using Gtk;

public class AccelGroupExample : Gtk.Application {
    private int click_count = 0;

    public AccelGroupExample() {
        Object(application_id: "org.gtk.AccelGroupExample",
               flags: ApplicationFlags.FLAGS_NONE);
    }

    protected override void activate() {
        var window = new ApplicationWindow(this) {
            title = "AccelGroup Example",
            default_width = 300,
            default_height = 200,
            window_position = WindowPosition.CENTER
        };

        var vbox = new Box(Orientation.VERTICAL, 10);
        window.add(vbox);

        var button = new Button.with_label("Click Me");
        vbox.pack_start(button, true, true, 0);

        var accel_group = new AccelGroup();
        window.add_accel_group(accel_group);

        button.add_accelerator("clicked", accel_group, (uint)Gdk.Key.c, Gdk.ModifierType.CONTROL_MASK, AccelFlags.VISIBLE);

        accel_group.connect((uint)Gdk.Key.c, Gdk.ModifierType.CONTROL_MASK, AccelFlags.VISIBLE, () => {
            click_count++;
            button.label = "Clicked %d times".printf(click_count);
            return false;
        });

        window.connect("destroy", Gtk.main_quit);
        
        window.show_all();
    }

    public static int main(string[] args) {
        var app = new AccelGroupExample();
        return app.run(args);
    }
}