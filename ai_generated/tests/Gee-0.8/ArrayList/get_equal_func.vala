using Gee;

public class Main {
    public static void main() {
        // Create an ArrayList of integers
        ArrayList<int> list = new ArrayList<int>();

        // Add some elements to the list
        list.add(1);
        list.add(2);
        list.add(3);
        list.add(4);
        list.add(5);

        // Set the equal function for the ArrayList
        list.set_equal_func(equal_func);

        // Search for an element using the custom comparison function
        int search_value = 3;
        ArrayList.Element<int>? found_element = list.find(search_value, (int a, int b) => {
            return a == b;
        });

        if (found_element != null) {
            stdout.printf("Element %d found at index %d\n", search_value, found_element.index);
        } else {
            stdout.printf("Element %d not found\n", search_value);
        }
    }
}