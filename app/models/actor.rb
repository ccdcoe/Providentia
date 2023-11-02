# frozen_string_literal: true

class Actor < ApplicationRecord
  has_ancestry

  belongs_to :exercise

  has_many :networks
  has_many :virtual_machines
  has_many :actor_number_configs
  has_many :numbered_virtual_machines, class_name: 'VirtualMachine', as: :numbered_by
  has_many :capabilities

  scope :numbered, -> {
    where.not(number: nil)
  }

  validates :number, numericality: { only_integer: true, greater_than: 0, allow_blank: true }

  before_save :set_exercise_from_parent

  def self.to_icon
    'fa-building-shield'
  end

  # THIS IS TEMPORARY UNTIL MIGRATED TO ACTORS
  def as_team_api
    case abbreviation
    when 'gt'
      {
        id: 'team_green',
        name: 'Green',
        config_map: {
          team_color: 'Green'
        },
        children: [],
        priority: 30
      }
    when 'rt'
      {
        id: 'team_red',
        name: 'Red',
        config_map: {
          team_color: 'Red'
        },
        children: [],
        priority: 30
      }
    when 'yt'
      {
        id: 'team_yellow',
        name: 'Yellow',
        config_map: {
          team_color: 'Yellow'
        },
        children: [],
        priority: 30
      }
    when 'bt'
      {
        id: 'team_blue',
        name: 'Blue',
        config_map: {
          team_color: 'Blue'
        },
        children: [],
        priority: 30
      }
    end
  end

  def red? # TEMPORARY
    abbreviation == 'rt'
  end

  def downcased_name
    name.downcase
  end

  def numbering
    return unless prefs['numbered']
    count = prefs.dig('numbered', 'count').presence || 0
    dev_count = prefs.dig('numbered', 'dev_count').presence || 0
    {
      entries: 1.step(by: 1).take(count + dev_count),
      dev_entries: (count + 1).step(by: 1).take(dev_count)
    }
  end

  def all_numbers
    return if !number?
    1.upto(number).to_a
  end

  def ui_color
    parent&.ui_color || prefs&.dig('ui_color') || 'gray'
  end

  private
    def set_exercise_from_parent
      return if exercise_id && !parent
      parent.exercise_id
    end
end
