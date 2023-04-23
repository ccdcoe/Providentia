# frozen_string_literal: true

class Service < ApplicationRecord
  include VmCacheBuster
  include SpecCacheUpdater
  extend FriendlyId
  friendly_id :name, use: :slugged, sequence_separator: '_'

  has_paper_trail

  belongs_to :exercise
  has_many :service_subjects, dependent: :destroy
  has_many :service_checks, dependent: :destroy
  has_many :special_checks, dependent: :destroy

  validates_associated :service_checks, :special_checks
  validates :name, uniqueness: { scope: :exercise }, presence: true, length: { minimum: 1, maximum: 63 }

  scope :for_spec, ->(*specs) {
    joins(:service_subjects)
      .where("service_subjects.customization_spec_ids @> ':id'::jsonb", id: specs.flatten.map(&:id))
  }

  def self.to_icon
    'fa-flask'
  end

  def self.migrate_to_subjects
    ServiceSubject.transaction do
      find_each do |service|
        service.customization_specs.each do |spec|
          service
            .service_subjects
            .where('match_conditions @> ?', [{ matcher_type: 'CustomizationSpec', matcher_id: spec.id.to_s }].to_json)
            .first_or_create!(match_conditions: [{ matcher_type: 'CustomizationSpec', matcher_id: spec.id.to_s }])
        end
      end
    end
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def cached_spec_ids
    service_subjects.pluck(:customization_spec_ids).flatten
  end
end
