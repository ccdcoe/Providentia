# frozen_string_literal: true

class FormErrorBoxComponent < ViewComponent::Base
  def initialize(form_object, id: nil)
    @form_object = form_object
    @id = id
  end

  def render?
    @form_object.errors.any?
  end
end
