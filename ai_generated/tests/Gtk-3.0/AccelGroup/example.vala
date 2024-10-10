using Gtk;
using GLib;

public class AccelGroupDemoApp : Gtk.Application {
    public AccelGroupDemoApp() {
        // Properly initialize the application
        Object(application_id: "org.gtk.AccelGroupDemoApp",
               flags: ApplicationFlags.FLAGS_NONE);
    }

    protected override void activate() {
        // Create the main application window
        var window = new ApplicationWindow(this) {
            title = "AccelGroup Demo",
            default_width = 500,
            default_height = 350,
            window_position = WindowPosition.CENTER
        };

        // Create an AccelGroup for managing keyboard shortcuts
        var accel_group = new AccelGroup();
        window.add_accel_group(accel_group);

        // Create a vertical box to hold widgets
        var vbox = new Box(Orientation.VERTICAL, 5);
        vbox.margin_top = 10;
        vbox.margin_bottom = 10;
        vbox.margin_start = 10;
        vbox.margin_end = 10;
        window.add(vbox);

        // Create a label to show information about actions
        var info_label = new Label("Press Ctrl+W to close, Alt+R to reset, Shift+F to find an accelerator, or Alt+H for Help.");
        vbox.pack_start(info_label, false, false, 0);

        // Create a Button and connect an action to it
        var button = new Button.with_label("Click me or press Alt+M!");
        button.clicked.connect(() => {
            info_label.label = "Button clicked! (Shortcut: Alt+M)";
        });
        vbox.pack_start(button, false, false, 0);

        // Add an accelerator for the button (Alt+M)
        button.add_accelerator("clicked", accel_group, (uint)Gdk.Key.m, Gdk.ModifierType.MOD1_MASK, AccelFlags.VISIBLE);

        // Set up actions for close, reset, help, find, activate, and programmatically activate
        accel_group.connect((uint)Gdk.Key.a, Gdk.ModifierType.CONTROL_MASK, AccelFlags.VISIBLE, () => {
            // Activate an accelerator programmatically
            var activated = accel_group.activate(Quark.from_string("clicked"), window, (uint)Gdk.Key.m, Gdk.ModifierType.MOD1_MASK);
            if (activated) {
                info_label.label = "Activated accelerator: Alt+M for button click.";
            } else {
                info_label.label = "No accelerator activated.";
            }
            return false;
        });

        // Set up actions for close, reset, help, and find
        accel_group.connect((uint)Gdk.Key.w, Gdk.ModifierType.CONTROL_MASK, AccelFlags.VISIBLE, () => {
            // Close the application
            window.close();
            return false;
        });

        accel_group.connect((uint)Gdk.Key.r, Gdk.ModifierType.MOD1_MASK, AccelFlags.VISIBLE, () => {
            // Reset the label text
            info_label.label = "Press Ctrl+W to close, Alt+R to reset, Shift+F to find an accelerator, or Alt+H for Help.";
            return false;
        });

        accel_group.connect((uint)Gdk.Key.h, Gdk.ModifierType.MOD1_MASK, AccelFlags.VISIBLE, () => {
            // Show a help message
            info_label.label = "Help: This is a demo showing how to use Gtk.AccelGroup with various keyboard shortcuts.";
            return false;
        });

        accel_group.connect((uint)Gdk.Key.f, Gdk.ModifierType.SHIFT_MASK, AccelFlags.VISIBLE, () => {
            // Find an accelerator in the AccelGroup
            var found_key = accel_group.find((key, closure) => {
                return key.accel_key == (uint)Gdk.Key.m && key.accel_mods == Gdk.ModifierType.MOD1_MASK;
            });
            if (found_key != null) {
                info_label.label = "Found accelerator: Alt+M for button click.";
            } else {
                info_label.label = "No matching accelerator found.";
            }
            return false;
        });

        // Show all widgets in the window
        window.show_all();
    }

    public static int main(string[] args) {
        var app = new AccelGroupDemoApp();
        return app.run(args);
    }
}