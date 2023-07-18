# frozen_string_literal: true

class ServiceSubjectMatchCondition
  include ActiveModel::Model

  attr_accessor :matcher_type, :matcher_id

  VALID_TYPES = [
    CustomizationSpec,
    OperatingSystem,
    Capability,
    Network,
    Actor,
    ActsAsTaggableOn::Tagging
  ]

  validates :matcher_type, inclusion: { in: VALID_TYPES.map(&:to_s), allow_blank: true }
  validates :matcher_id, numericality: true, allow_blank: true, unless: -> { matcher_type == 'ActsAsTaggableOn::Tagging' }

  def attributes
    {
      matcher_type:,
      matcher_id:
    }
  end

  def id
    Digest::SHA1.hexdigest(attributes.to_yaml)
  end

  def ==(other)
    other.is_a?(self.class) && other.attributes == attributes
  end

  def matched
    matcher_type.constantize.where(id: matcher_id)
  end
end
