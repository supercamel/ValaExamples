public class DatagramIPv4 : Object {

    public DatagramIPv4(GLib.MainContext? context) {
        // If no context is provided, use the default context
        if(context == null) {
            this.context = GLib.MainContext.default();
        }
        else {
            this.context = context;
        }
        // Create a new UDP socket using IPv4
        try {
            socket = new Socket(SocketFamily.IPV4, SocketType.DATAGRAM, SocketProtocol.UDP);
        }
        catch(Error e) {
            // Handle error
            stdout.printf("Error: %s\n", e.message);
            return;
        }
    }
    
    public bool listen(uint16 port, InetAddress? address) {
        try {
            // If no address is provided, bind to any IPv4 address
            if(address == null) {
                var any_address = new InetAddress.any(SocketFamily.IPV4);
                var socket_address = new InetSocketAddress(any_address, port);
                socket.bind(socket_address, false);
            }
            else {
                // Bind to the specified address and port
                var socket_address = new InetSocketAddress(address, port);
                socket.bind(socket_address, false);
            }
            // Create a source for the socket to monitor incoming data
            var socket_source = socket.create_source(IOCondition.IN);
            // Set a callback for when data is available
            socket_source.set_callback((s, condition) => {
                // Read the available data
                var data = new uint8[s.get_available_bytes()];
                try {
                    s.receive(data);
                    // Emit the on_data signal with the received data
                    on_data(data);
                }
                catch(Error e) {
                    print("Error: %s\n", e.message);
                }
                return true;
            });
            // Attach the source to the context
            socket_source.attach(context);
        } catch(Error e) {
            // Print any errors that occur
            print("Error: %s\n", e.message);
            return false;
        }
        return true;
    }
    
    public void send_to(string host_or_ip, uint16 port, uint8[] data) {
        InetAddress address;
        // Resolve the host or IP address
        if(resolve(host_or_ip, out address)) {
            // Create a socket address using the resolved address and port
            var addr = new InetSocketAddress(address, port);
            // Send the data to the specified address
            try {
                socket.send_to(addr, data);
            }
            catch (Error e) {
                // Print any errors that occur
                print("Error: %s\n", e.message);
            }
        }
    }
    
    private bool resolve(string host_or_ip, out InetAddress address) {
        // Check if the input is an IPv4 address
        if(string_is_ipv4(host_or_ip)) {
            // Create an InetAddress from the IPv4 string
            address = new InetAddress.from_string(host_or_ip);
            return true;
        }
        else {
            // Resolve the hostname
            var resolver = Resolver.get_default();
            try {
                List<InetAddress> addresses = resolver.lookup_by_name (host_or_ip, null);
                foreach (var addr in addresses) {
                    // Find the first IPv4 address in the resolved addresses
                    if(addr.family == SocketFamily.IPV4) {
                        address = addr;
                        return true;
                    }
                }
            }
            catch (Error e) { }
        }
        // Print an error if the hostname couldn't be resolved
        stdout.printf("Failed to resolve hostname: %s\n", host_or_ip);
        address = new InetAddress.any(SocketFamily.IPV4);
        return false;
    }
    
    private bool string_is_ipv4(string ip) {
        // Split the IP string into octets
        var splits = ip.split(".");
        // Check if there are exactly 4 octets
        if (splits.length != 4) {
            return false;
        }
        foreach (var split in splits) {
            // Check if each octet has at most 3 digits
            if(split.length > 3) {
                return false;
            }
            foreach (var c in split.data) {
                // Check if each character is a digit
                if (c < '0' || c > '9') {
                    return false;
                }
            }
            uint val;
            // Try to parse each octet as an unsigned integer
            if (uint.try_parse(split, out val) == false) {
                return false;
            }
            // Check if each octet is between 0 and 255
            if(val > 255) {
                return false;
            }
        }
        return true;
    }
    
    // Signal emitted when data is received
    public signal void on_data(uint8[] data);
    
    private GLib.MainContext context;
    private Socket socket;
    
}
    
public void main (string[] args) {
    // Create a new main loop
    var loop = new GLib.MainLoop();
    // Create a new DatagramIPv4 instance using the main loop's context
    var datagram = new DatagramIPv4(loop.get_context());
    // Start listening on port 15005 for any IPv4 address
    datagram.listen(15005, null);
    // Connect to the on_data signal to handle received data
    datagram.on_data.connect((data) => {
        stdout.printf("Received: %s\n", (string)data);
    });
    // Add a timeout to send data after 100 milliseconds
    Timeout.add(100, () => {
        datagram.send_to("localhost", 15005, "Hello World".data);
        // Cancel the timeout
        return false;
    });
    // Add a timeout to quit the main loop after 150 milliseconds
    Timeout.add(150, () => {
        loop.quit();
        return false;
    });
    // Run the main loop
    loop.run();
}