using Gee;

public class Main {
    public static void main(string[] args) {
        // Create an ArrayList of integers
        ArrayList<int> list = new ArrayList<int>();

        // Add elements to the list
        list.add(1);
        list.add(2);
        list.add(3);

        // Print the list
        print("Original list: ");
        foreach (int i in list) {
            print("%d ", i);
        }
        print("\n");

        // Create another ArrayList
        ArrayList<int> additional_list = new ArrayList<int>();
        additional_list.add(4);
        additional_list.add(5);
        additional_list.add(6);

        // Add all elements from additional_list to list
        list.add_all(additional_list);

        // Print the updated list
        print("Updated list after adding all elements from additional_list: ");
        foreach (int i in list) {
            print("%d ", i);
        }
        print("\n");
    }
}