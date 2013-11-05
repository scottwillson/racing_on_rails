module Concerns
  module TreeExtensions
    extend ActiveSupport::Concern

    def root
      node = self
      node = node.parent while node.parent
      node
    end

    def ancestors
      node, nodes = self, []
      nodes << node = node.parent while node.parent
      nodes
    end

    # All children and children childrens
    def descendants
      _descendants = children(true)
      children.each do |child|
        _descendants = _descendants + child.descendants
      end
      _descendants
    end
  end
end
