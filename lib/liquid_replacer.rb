# frozen_string_literal: true

class LiquidReplacer < Struct.new(:input)
  def iterate
    Liquid::Template.parse(input).root.nodelist.map do |node|
      if node.is_a?(Liquid::Variable)
        yield(node)
      else
        node
      end
    end.join('')
  end
end
