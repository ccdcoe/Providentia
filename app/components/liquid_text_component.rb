# frozen_string_literal: true

class LiquidTextComponent < LiquidTooltipSnippetComponent
  attr_reader :actor

  def initialize(object:, actor:)
    @object = object
    @actor = actor
  end

  private
    def template_text
      @object
    end
end
