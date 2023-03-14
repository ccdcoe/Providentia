# frozen_string_literal: true

class ActorNumberingForm < Patterns::Form
  param_key 'numbering'

  attribute :count,
    Integer,
    default: ->(form, attribute) { form.send(:resource).prefs.dig('numbered', 'count') },
    nullify_blank: true

  attribute :dev_count,
    Integer,
    default: ->(form, attribute) { form.send(:resource).prefs.dig('numbered', 'dev_count') },
    nullify_blank: true

  validates :count, :dev_count, numericality: { greater_than_or_equal_to: 0, allow_blank: true }

  private
    def persist
      if attributes.values.all?(&:nil?)
        resource.prefs.delete('numbered')
      else
        resource.prefs[:numbered] ||= {}
        resource.prefs[:numbered].merge!(attributes)
      end
      resource.save
    end
end
