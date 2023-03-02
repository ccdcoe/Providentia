# frozen_string_literal: true

class Service < ApplicationRecord
  include VmCacheBuster

  has_paper_trail

  belongs_to :exercise
  has_many :service_checks, dependent: :destroy
  has_many :special_checks, dependent: :destroy

  has_and_belongs_to_many :customization_specs

  validates_associated :service_checks, :special_checks
  validates :name, uniqueness: { scope: :exercise }, presence: true, length: { minimum: 1, maximum: 63 }

  scope :for_api, -> {
    eager_load(service_checks: [:network, :service], special_checks: [:network, :service])
      .flat_map do |service|
        service.service_checks.flat_map(&:virtual_checks).map(&:slug) +
          service.special_checks.map(&:slug)
      end
  }

  def self.to_icon
    'fa-flask'
  end
end
