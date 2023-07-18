# frozen_string_literal: true

require 'service_subject_match_condition'

class ServiceSubject < ApplicationRecord
  include SpecCacheUpdater

  has_paper_trail

  belongs_to :service, touch: true
  has_one :exercise, through: :service

  attribute :match_conditions, ActiveModelListType.new(ServiceSubjectMatchCondition)

  before_create :add_default_empty_matcher
  before_save :reset_match_condition_id_if_type_changed, if: :match_conditions_changed?

  validates_associated :match_conditions

  scope :search_matcher, ->(*items) {
    temp_scope = joins('cross join lateral jsonb_array_elements(match_conditions) el')
      .where('service_id is null') # dummy condition so OR will work
    [items].flatten.reduce(temp_scope) do |scope, item|
      scope.or(ServiceSubject.where('el @> :matcher',
        matcher: {
          matcher_id: item.id.to_s,
          matcher_type: item.class.to_s
        }.to_json
      ))
    end
  }

  def self.to_icon
    'fa-flask'
  end

  def matched_spec_ids
    return [] unless match_conditions.any?
    match_conditions.reduce(exercise.customization_specs.scope) do |scope, condition|
      case condition.matcher_type
      when 'CustomizationSpec'
        scope.where(id: condition.matcher_id)
      when 'Network'
        scope.joins(virtual_machine: :network_interfaces).merge(NetworkInterface.egress).where(network_interfaces: { network_id: condition.matcher_id })
      when 'Capability'
        scope.joins(:capabilities).where(capabilities: { id: condition.matcher_id })
      when 'Actor'
        scope.joins(virtual_machine: :actor).where(actors: { id: condition.matcher_id })
      when 'OperatingSystem'
        if condition.matcher_id.blank?
          scope.none
        else
          scope
            .joins(virtual_machine: :operating_system)
            .where(operating_systems: { id: OperatingSystem.find(condition.matcher_id).subtree_ids })
        end
      when 'ActsAsTaggableOn::Tagging'
        scope.tagged_with(condition.matcher_id)
      else
        scope.none
      end
    end.pluck(:id)
  end

  private
    def add_default_empty_matcher
      match_conditions << ServiceSubjectMatchCondition.new(matcher_type: nil, matcher_id: nil) if match_conditions.empty?
    end

    def reset_match_condition_id_if_type_changed
      return if match_conditions_change.last.size != match_conditions_change.first.size
      match_conditions_change.transpose.each do |(before, after)|
        after.matcher_id = nil if before.matcher_type != after.matcher_type
      end
    end
end
