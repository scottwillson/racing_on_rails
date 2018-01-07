# frozen_string_literal: true

module ActsAsTree
  module Extensions
    extend ActiveSupport::Concern

    # Returns list of ancestors, starting from parent until root.
    #
    #   subchild1.ancestors # => [child1, root]
    def ancestors
      node = self
      nodes = []
      nodes << node = node.parent while node.parent
      nodes
    end

    # Dupe from acts_as_tree gem so Event can use it.
    def descendants
      children.each_with_object(children.to_a) do |child, arr|
        arr.concat child.descendants
      end.uniq
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
