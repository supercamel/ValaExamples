using Gtk;

public class AcceleratorExample : Gtk.Window {
    private int click_count = 0;

    public AcceleratorExample() {
        // Initialize the window
        this.title = "Accelerator Example";
        this.window_position = WindowPosition.CENTER;
        this.destroy.connect(Gtk.main_quit);
        this.set_default_size(300, 200);

        // Create a button
        Gtk.Button button = new Gtk.Button.with_label("Click Me (0)");
        this.add(button);

        // Create an AccelGroup
        AccelGroup accel_group = new AccelGroup();
        this.add_accel_group(accel_group);

        // Connect the button's clicked signal to a custom handler
        button.clicked.connect(() => {
            click_count++;
            button.label = "Click Me (%d)".printf(click_count);
        });

        // Add an accelerator for the button (Ctrl+Shift+C)
        button.add_accelerator("clicked", accel_group, (uint)Gdk.Key.c, Gdk.ModifierType.CONTROL_MASK | Gdk.ModifierType.SHIFT_MASK, AccelFlags.VISIBLE);
    }

    public static int main(string[] args) {
        Gtk.init(ref args);

        AcceleratorExample app = new AcceleratorExample();
        app.show_all();
        Gtk.main();

        return 0;
    }
}