# frozen_string_literal: true

class ActorAPIName < Patterns::Calculation
  def result
    %w(actor).tap do |builder|
      builder << subject.abbreviation.parameterize
      if options[:numbered_by]
        builder << options[:numbered_by].abbreviation.parameterize
        builder << 'numbered'
      end
      builder << 't' + options[:number].to_s.rjust(2, '0') if options[:number]
    end.join('_').downcase.tr('-', '_')
  end
end
