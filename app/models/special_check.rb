# frozen_string_literal: true

class SpecialCheck < ApplicationRecord
  include VmCacheBuster
  has_paper_trail

  belongs_to :service, touch: true
  belongs_to :network, optional: true
  has_one :exercise, through: :service
  has_many :customization_specs, through: :service

  validates :name, presence: true

  def self.to_icon
    'fa-flask'
  end

  def display_name
    name
  end

  def slug
    [
      service.name,
      network&.abbreviation,
      name
    ].compact.join '-'
  end
end
