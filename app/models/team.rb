# frozen_string_literal: true

class Team < ApplicationRecord
  has_many :virtual_machines
  has_many :networks

  attr_accessor :exercise # dummy until better fix

  def self.to_icon
    'fa-users'
  end

  def abbreviation
    "#{name[0].upcase}T"
  end

  def api_short_name
    "team_#{name}".downcase
  end

  def blue?
    name.downcase == 'blue'
  end

  def red?
    name.downcase == 'red'
  end

  def green?
    name.downcase == 'green'
  end

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
