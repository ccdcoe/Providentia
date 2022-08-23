# frozen_string_literal: true

class ColumnFormSectionComponent < ViewComponent::Base
  renders_one :description
  renders_one :main

  def initialize(disabled: false, shadow: true)
    @disabled = disabled
    @shadow = shadow
  end
end
