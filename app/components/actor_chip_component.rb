# frozen_string_literal: true

class ActorChipComponent < ViewComponent::Base
  def initialize(actor:, text: nil)
    @actor = actor
    @text = text
  end

  private
    def css_classes
      helpers.actor_color_classes(@actor)
    end
end
