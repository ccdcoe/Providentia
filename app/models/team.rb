# frozen_string_literal: true

class Team < ApplicationRecord
  has_many :virtual_machines
  has_many :networks

  def ui_color
    case name
    when 'Green'
      'emerald'
    when 'White'
      'stone'
    when 'Blue'
      'sky'
    when 'Red'
      'rose'
    when 'Yellow'
      'yellow'
    end
  end
end
