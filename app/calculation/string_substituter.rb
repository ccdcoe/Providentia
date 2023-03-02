# frozen_string_literal: true

class StringSubstituter < Patterns::Calculation
  VALID_LIQUID_KEYS = %i(seq team_nr)

  private
    def result
      numbering_substitution(liquid_substitution)
    end

    def numbering_substitution(text)
      NumberingTools.substitute(text, options[:team_nr])
    end

    def liquid_substitution
      Liquid::Template.parse(subject, error_mode: :strict)
        .render(options.slice(*VALID_LIQUID_KEYS).stringify_keys)
    end
end
