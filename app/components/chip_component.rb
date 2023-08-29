# frozen_string_literal: true

class ChipComponent < ViewComponent::Base
  with_collection_parameter :name

  def initialize(name:)
    @name = name
  end
end
