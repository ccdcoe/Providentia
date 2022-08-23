# frozen_string_literal: true

class LiquidTextComponent < LiquidTooltipSnippetComponent
  attr_reader :exercise

  def initialize(object:, exercise:)
    @object = object
    @exercise = exercise
  end

  private
    def template_text
      @object
    end
end
