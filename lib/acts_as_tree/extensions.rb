module ActsAsTree
  module Extensions
    extend ActiveSupport::Concern

    # Returns list of ancestors, starting from parent until root.
    #
    #   subchild1.ancestors # => [child1, root]
    def ancestors
      node, nodes = self, []

      while node.parent do
        nodes << node = node.parent
        if nodes.include?(node.parent)
          break
        end
      end

      nodes
    end

    # Dupe from acts_as_tree gem so Event can use it.
    def descendants
      children.each_with_object(children) {|child, arr|
        arr.concat child.descendants
      }.uniq
    end

    # Returns the root node of the tree.
    # Dupe from acts_as_tree gem so Event can use it.
    def root
      node = self
      node = node.parent while node.parent
      node
    end
  end
end
