# frozen_string_literal: true

class DomWrapperComponent < ViewComponent::Base
  def initialize(classes: nil, id: nil)
    @classes = classes
    @id = id
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
