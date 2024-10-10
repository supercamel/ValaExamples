using Gtk;

public class AcceleratorExample : Gtk.Window {
    private AccelGroup accel_group;

    public AcceleratorExample() {
        // Initialize the window
        this.title = "Accelerator Example";
        this.window_position = WindowPosition.CENTER;
        this.destroy.connect(Gtk.main_quit);
        this.set_default_size(300, 200);

        // Create an AccelGroup for managing keyboard shortcuts
        accel_group = new AccelGroup();
        this.add_accel_group(accel_group);

        // Create a button and add it to the window
        var button = new Button.with_label("Click Me");
        this.add(button);

        // Connect an accelerator to the button (Ctrl+R)
        button.add_accelerator("clicked", accel_group, (uint)Gdk.Key.r, Gdk.ModifierType.CONTROL_MASK, AccelFlags.VISIBLE);

        // Connect a signal handler to the button's clicked event
        button.clicked.connect(() => {
            stdout.printf("Button clicked!\n");
        });

        // Connect a signal handler to the window's key-press-event to disconnect the accelerator
        this.key_press_event.connect((widget, event) => {
            if (event.keyval == (uint)Gdk.Key.r && (event.state & Gdk.ModifierType.CONTROL_MASK) != 0) {
                accel_group.disconnect_key((uint)Gdk.Key.r, Gdk.ModifierType.CONTROL_MASK);
                stdout.printf("Accelerator disconnected for Ctrl+R\n");
                return true; // Stop further processing of the event
            }
            return false; // Continue processing the event
        });
    }

    public static int main(string[] args) {
        Gtk.init(ref args);

        AcceleratorExample app = new AcceleratorExample();
        app.show_all();
        Gtk.main();

        return 0;
    }
}