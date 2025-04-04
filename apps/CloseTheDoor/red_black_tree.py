class Node:
    def __init__(self, key, color="RED"):
        self.key = key
        self.left = None
        self.right = None
        self.parent = None
        self.color = color  # "RED" or "BLACK"

class RedBlackTree:
    def __init__(self):
        # NIL node - represents leaf nodes (all leaves are NIL)
        self.NIL = Node(None, "BLACK")
        self.NIL.left = None
        self.NIL.right = None
        self.NIL.parent = None
        
        # Root of the tree
        self.root = self.NIL
    
    def search(self, key):
        """Search for a key in the tree"""
        return self._search_helper(self.root, key)
    
    def _search_helper(self, node, key):
        """Recursive helper for search"""
        if node == self.NIL or key == node.key:
            return node
        
        if key < node.key:
            return self._search_helper(node.left, key)
        return self._search_helper(node.right, key)
    
    def insert(self, key):
        """Insert a key into the tree"""
        # Create new node
        new_node = Node(key, "RED")
        new_node.left = self.NIL
        new_node.right = self.NIL
        
        # Perform standard BST insert
        y = None
        x = self.root
        
        while x != self.NIL:
            y = x
            if new_node.key < x.key:
                x = x.left
            else:
                x = x.right
        
        # Set the parent of new node
        new_node.parent = y
        
        # Assign new node as root or as the correct child of its parent
        if y is None:
            self.root = new_node
        elif new_node.key < y.key:
            y.left = new_node
        else:
            y.right = new_node
        
        # If the tree was empty, color the root black and return
        if new_node.parent is None:
            new_node.color = "BLACK"
            return
        
        # If the grandparent is None, return
        if new_node.parent.parent is None:
            return
        
        # Fix violations of red-black properties
        self._fix_insert(new_node)
    
    def _fix_insert(self, k):
        """Fix Red-Black Tree properties after insertion"""
        while k.parent and k.parent.color == "RED":
            if k.parent == k.parent.parent.right:
                # Parent is the right child of grandparent
                u = k.parent.parent.left  # Uncle
                
                if u.color == "RED":
                    # Case 1: Uncle is red
                    u.color = "BLACK"
                    k.parent.color = "BLACK"
                    k.parent.parent.color = "RED"
                    k = k.parent.parent
                else:
                    if k == k.parent.left:
                        # Case 2: Uncle is black and k is a left child
                        k = k.parent
                        self._right_rotate(k)
                    
                    # Case 3: Uncle is black and k is a right child
                    k.parent.color = "BLACK"
                    k.parent.parent.color = "RED"
                    self._left_rotate(k.parent.parent)
            else:
                # Parent is the left child of grandparent (symmetrical to above cases)
                u = k.parent.parent.right  # Uncle
                
                if u.color == "RED":
                    # Case 1: Uncle is red
                    u.color = "BLACK"
                    k.parent.color = "BLACK"
                    k.parent.parent.color = "RED"
                    k = k.parent.parent
                else:
                    if k == k.parent.right:
                        # Case 2: Uncle is black and k is a right child
                        k = k.parent
                        self._left_rotate(k)
                    
                    # Case 3: Uncle is black and k is a left child
                    k.parent.color = "BLACK"
                    k.parent.parent.color = "RED"
                    self._right_rotate(k.parent.parent)
            
            if k == self.root:
                break
        
        # Ensure root is black
        self.root.color = "BLACK"
    
    def _left_rotate(self, x):
        """Perform left rotation"""
        y = x.right
        x.right = y.left
        
        if y.left != self.NIL:
            y.left.parent = x
        
        y.parent = x.parent
        
        if x.parent is None:
            self.root = y
        elif x == x.parent.left:
            x.parent.left = y
        else:
            x.parent.right = y
        
        y.left = x
        x.parent = y
    
    def _right_rotate(self, y):
        """Perform right rotation"""
        x = y.left
        y.left = x.right
        
        if x.right != self.NIL:
            x.right.parent = y
        
        x.parent = y.parent
        
        if y.parent is None:
            self.root = x
        elif y == y.parent.left:
            y.parent.left = x
        else:
            y.parent.right = x
        
        x.right = y
        y.parent = x
    
    def delete(self, key):
        """Delete a node with given key from the tree"""
        self._delete_helper(self.root, key)
    
    def _delete_helper(self, node, key):
        """Recursive helper for delete"""
        z = self.NIL
        
        # Find the node to delete
        while node != self.NIL:
            if node.key == key:
                z = node
                break
            
            if key < node.key:
                node = node.left
            else:
                node = node.right
        
        if z == self.NIL:
            print(f"Key {key} not found in the tree")
            return
        
        # y is the node to be removed or moved within the tree
        y = z
        y_original_color = y.color
        
        # x is the node that will replace y
        if z.left == self.NIL:
            # z has only right child or no children
            x = z.right
            self._transplant(z, z.right)
        elif z.right == self.NIL:
            # z has only left child
            x = z.left
            self._transplant(z, z.left)
        else:
            # z has both children
            # Find the successor (minimum in right subtree)
            y = self._minimum(z.right)
            y_original_color = y.color
            x = y.right
            
            if y.parent == z:
                # y is direct child of z
                x.parent = y
            else:
                # y is deeper in the tree
                self._transplant(y, y.right)
                y.right = z.right
                y.right.parent = y
            
            self._transplant(z, y)
            y.left = z.left
            y.left.parent = y
            y.color = z.color
        
        # If the original color was BLACK, fix the tree
        if y_original_color == "BLACK":
            self._fix_delete(x)
    
    def _transplant(self, u, v):
        """Replace subtree rooted at u with subtree rooted at v"""
        if u.parent is None:
            self.root = v
        elif u == u.parent.left:
            u.parent.left = v
        else:
            u.parent.right = v
        
        v.parent = u.parent
    
    def _minimum(self, node):
        """Find the node with minimum key in the subtree rooted at node"""
        while node.left != self.NIL:
            node = node.left
        return node
    
    def _fix_delete(self, x):
        """Fix Red-Black Tree properties after deletion"""
        while x != self.root and x.color == "BLACK":
            if x == x.parent.left:
                # x is a left child
                w = x.parent.right  # sibling
                
                if w.color == "RED":
                    # Case 1: Sibling is red
                    w.color = "BLACK"
                    x.parent.color = "RED"
                    self._left_rotate(x.parent)
                    w = x.parent.right
                
                if w.left.color == "BLACK" and w.right.color == "BLACK":
                    # Case 2: Sibling and its children are black
                    w.color = "RED"
                    x = x.parent
                else:
                    if w.right.color == "BLACK":
                        # Case 3: Sibling is black, its left child is red, right child is black
                        w.left.color = "BLACK"
                        w.color = "RED"
                        self._right_rotate(w)
                        w = x.parent.right
                    
                    # Case 4: Sibling is black, its right child is red
                    w.color = x.parent.color
                    x.parent.color = "BLACK"
                    w.right.color = "BLACK"
                    self._left_rotate(x.parent)
                    x = self.root
            else:
                # x is a right child (symmetrical to the above cases)
                w = x.parent.left  # sibling
                
                if w.color == "RED":
                    # Case 1: Sibling is red
                    w.color = "BLACK"
                    x.parent.color = "RED"
                    self._right_rotate(x.parent)
                    w = x.parent.left
                
                if w.right.color == "BLACK" and w.left.color == "BLACK":
                    # Case 2: Sibling and its children are black
                    w.color = "RED"
                    x = x.parent
                else:
                    if w.left.color == "BLACK":
                        # Case 3: Sibling is black, its right child is red, left child is black
                        w.right.color = "BLACK"
                        w.color = "RED"
                        self._left_rotate(w)
                        w = x.parent.left
                    
                    # Case 4: Sibling is black, its left child is red
                    w.color = x.parent.color
                    x.parent.color = "BLACK"
                    w.left.color = "BLACK"
                    self._right_rotate(x.parent)
                    x = self.root
        
        x.color = "BLACK"
    
    def inorder_traversal(self):
        """Perform inorder traversal of the tree"""
        result = []
        self._inorder_helper(self.root, result)
        return result
    
    def _inorder_helper(self, node, result):
        """Recursive helper for inorder traversal"""
        if node != self.NIL:
            self._inorder_helper(node.left, result)
            result.append((node.key, node.color))
            self._inorder_helper(node.right, result)
    
    def print_tree(self):
        """Print the tree structure"""
        self._print_helper(self.root, "", True)
    
    def _print_helper(self, node, indent, last):
        """Recursive helper for printing the tree"""
        if node != self.NIL:
            print(indent, end="")
            if last:
                print("R----", end="")
                indent += "     "
            else:
                print("L----", end="")
                indent += "|    "
            
            color = "RED" if node.color == "RED" else "BLACK"
            print(f"{node.key}({color})")
            
            self._print_helper(node.left, indent, False)
            self._print_helper(node.right, indent, True)


# Example usage
if __name__ == "__main__":
    rb_tree = RedBlackTree()
    
    # Insert some values
    keys = [7, 3, 18, 10, 22, 8, 11, 26, 2, 6, 13]
    for key in keys:
        rb_tree.insert(key)
    
    print("Inorder traversal of the tree:")
    print(rb_tree.inorder_traversal())
    
    print("\nTree structure:")
    rb_tree.print_tree()
    
    print("\nDeleting 18, 11, 3...")
    rb_tree.delete(18)
    rb_tree.delete(11)
    rb_tree.delete(3)
    
    print("\nTree structure after deletion:")
    rb_tree.print_tree()
    
    print("\nSearching for key 10:")
    node = rb_tree.search(10)
    if node != rb_tree.NIL:
        print(f"Found node with key {node.key}, color: {node.color}")
    else:
        print("Key not found") 