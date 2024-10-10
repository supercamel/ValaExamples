using Gtk;

public class AccelGroupExample : Gtk.Application {
    private AccelGroup accel_group;
    private Button button;

    public AccelGroupExample() {
        Object(application_id: "org.gtk.AccelGroupExample",
               flags: ApplicationFlags.FLAGS_NONE);
    }

    protected override void activate() {
        Window window = new Window();
        window.title = "AccelGroup Example";
        window.default_width = 300;
        window.default_height = 200;
        window.window_position = WindowPosition.CENTER;
        window.destroy.connect(Gtk.main_quit);

        accel_group = new AccelGroup();
        window.add_accel_group(accel_group);

        button = new Button.with_label("Click Me");
        button.clicked.connect(() => {
            stdout.printf("Button clicked!\n");
        });

        // Add an accelerator for the button (Ctrl+Shift+C)
        button.add_accelerator("clicked", accel_group, (uint)Gdk.Key.c, Gdk.ModifierType.CONTROL_MASK | Gdk.ModifierType.SHIFT_MASK, AccelFlags.VISIBLE);

        window.add(button);
        window.show_all();
    }

    public static int main(string[] args) {
        AccelGroupExample app = new AccelGroupExample();
        return app.run(args);
    }
}