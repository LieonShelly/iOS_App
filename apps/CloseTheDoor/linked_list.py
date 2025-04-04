class Node:
    def __init__(self, data):
        self.data = data
        self.next = None

class LinkedList:
    def __init__(self):
        self.head = None
    
    def is_empty(self):
        return self.head is None
    
    def append(self, data):
        new_node = Node(data)
        if self.is_empty():
            self.head = new_node
            return
        
        current = self.head
        while current.next:
            current = current.next
        current.next = new_node
    
    def prepend(self, data):
        new_node = Node(data)
        new_node.next = self.head
        self.head = new_node
    
    def insert_after(self, prev_node, data):
        if not prev_node:
            print("Previous node cannot be None")
            return
        
        new_node = Node(data)
        new_node.next = prev_node.next
        prev_node.next = new_node
    
    def delete_node(self, key):
        temp = self.head
        
        # If head node itself holds the key to be deleted
        if temp and temp.data == key:
            self.head = temp.next
            temp = None
            return
        
        # Search for the key to be deleted, keep track of the
        # previous node as we need to change 'prev.next'
        while temp:
            if temp.data == key:
                break
            prev = temp
            temp = temp.next
        
        # If key was not present in linked list
        if not temp:
            return
        
        # Unlink the node from linked list
        prev.next = temp.next
        temp = None
    
    def print_list(self):
        current = self.head
        while current:
            print(current.data, end=" -> ")
            current = current.next
        print("None")


# Example usage
if __name__ == "__main__":
    llist = LinkedList()
    
    llist.append(1)
    llist.append(2)
    llist.append(3)
    llist.prepend(0)
    
    print("Linked list:")
    llist.print_list()
    
    print("Deleting node with value 2:")
    llist.delete_node(2)
    llist.print_list()
    
    print("Inserting 5 after head:")
    llist.insert_after(llist.head, 5)
    llist.print_list() 