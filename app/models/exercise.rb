# frozen_string_literal: true

class Exercise < ApplicationRecord
  extend FriendlyId
  has_paper_trail

  enum mode: {
    exercise: 1,
    infra: 2
  }, _prefix: :mode

  has_many :networks, dependent: :destroy
  has_many :virtual_machines, dependent: :destroy
  has_many :services, dependent: :destroy
  has_many :capabilities, dependent: :destroy
  has_many :address_pools, through: :networks
  has_many :addresses, through: :virtual_machines
  has_many :customization_specs, through: :virtual_machines

  validates :blue_team_count, :dev_team_count,
    numericality: { only_integer: true, greater_than_or_equal_to: 1 },
    allow_blank: true
  validates :name, :abbreviation, presence: true
  validates :abbreviation, uniqueness: true

  friendly_id :abbreviation, use: :slugged

  scope :active, -> { where(archived: false) }

  def self.to_icon
    'fa-project-diagram'
  end

  def last_dev_bt
    blue_team_count.to_i + dev_team_count.to_i
  end

  def all_blue_teams
    1.upto(last_dev_bt).to_a
  end

  def dev_blue_teams
    return [] if last_dev_bt.zero?
    ((blue_team_count + 1)..last_dev_bt).to_a
  end

  # friendlyid override
  def should_generate_new_friendly_id?
    abbreviation_changed? || super
  end
end
