# frozen_string_literal: true

class ConfigMapForm < Patterns::Form
  param_key 'cm'

  attribute :config_map_as_yaml,
    String,
    default: ->(form, attribute) { form.send(:resource).config_map.to_yaml }
  attribute :parsed_config_map, Enumerable, writer: :private

  validate :valid_yaml?

  private
    def valid_yaml?
      self.parsed_config_map = Psych.safe_load(config_map_as_yaml)
    rescue Psych::SyntaxError
      errors.add(:config_map_as_yaml, :invalid)
    end

    def persist
      resource.update(
        config_map: parsed_config_map
      )
    end
end
