# frozen_string_literal: true

class ActorTreeComponent < ViewComponent::Base
  def initialize(tree:)
    @tree = tree
  end

  def render?
    @tree.any?
  end

  private
    def spacer_classes(node)
      "pl-#{(node.depth - 1) * 2} ml-#{(node.depth - 1) * 2}"
    end
end
