# frozen_string_literal: true

class Actor < ApplicationRecord
  has_ancestry

  belongs_to :exercise

  has_many :networks
  has_many :virtual_machines
  has_many :actor_number_configs
  has_many :numbered_virtual_machines, class_name: 'VirtualMachine', foreign_key: :numbered_by

  scope :numbered, -> {
    where.not(number: nil)
  }

  validates :number, numericality: { only_integer: true, greater_than: 0, allow_blank: true }

  before_save :set_exercise_from_parent

  ### TEMPORARY: until migrated
  def self.migrate_from_teams
    Exercise.find_each do |ex|
      ex.actors
        .where(abbreviation: 'admin')
        .first_or_create(name: 'Exercise admin')
        .update!(
          prefs: {
            ui_color: Team.find_by(name: 'Green').ui_color
          }
        )
      ex.actors
        .where(abbreviation: 'gt')
        .first_or_create(name: 'Green team')
        .update!(
          prefs: {
            ui_color: Team.find_by(name: 'Green').ui_color
          }
        )
      ex.actors
        .where(abbreviation: 'yt')
        .first_or_create(name: 'Yellow team')
        .update!(
          prefs: {
            ui_color: Team.find_by(name: 'Yellow').ui_color
          }
        )
      ex.actors
        .where(abbreviation: 'rt')
        .first_or_create(name: 'Red team')
        .update!(
          prefs: {
            ui_color: Team.find_by(name: 'Red').ui_color
          }
        )

      prefs = if ex.blue_team_count || ex.dev_team_count
        {
          ui_color: Team.find_by(name: 'Blue').ui_color,
          numbered: { count: ex.blue_team_count, dev_count: ex.dev_team_count }
        }
      else
        {
          ui_color: Team.find_by(name: 'Blue').ui_color
        }
      end
      bt = ex.actors.where(abbreviation: 'bt').first_or_create(name: 'Blue teams')
      bt.update!(prefs:)

      ex.networks.find_each do |net|
        next unless net.team
        net.update actor: ex.actors.find_by(abbreviation: abbreviation_for_team(net.team)) || ex.actors.first
      end

      ex.virtual_machines.find_each do |vm|
        next unless vm.team
        vm.update actor: ex.actors.find_by(abbreviation: abbreviation_for_team(vm.team)) || ex.actors.first
        if vm.deploy_mode_bt?
          vm.update numbered_actor: bt
        end
      end
    end
  end

  ### TEMPORARY: until migrated
  def self.abbreviation_for_team(team)
    case team.name
    when 'Red'
      :rt
    when 'Green'
      :gt
    when 'Yellow'
      :yt
    when 'Blue'
      :bt
    end
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
        children: []
      }
    when 'rt'
      {
        id: 'team_red',
        name: 'Red',
        config_map: {
          team_color: 'Red'
        },
        children: []
      }
    when 'yt'
      {
        id: 'team_yellow',
        name: 'Yellow',
        config_map: {
          team_color: 'Yellow'
        },
        children: []
      }
    when 'bt'
      {
        id: 'team_blue',
        name: 'Blue',
        config_map: {
          team_color: 'Blue'
        },
        children: []
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
