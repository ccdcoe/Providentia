# frozen_string_literal: true

class ClassWrapperComponent < ViewComponent::Base
  def initialize(classes: nil)
    @classes = classes
  end

  private
    def classes
      if @classes.is_a?(Array)
        @classes.join ' '
      else
        @classes
      end
    end
end
