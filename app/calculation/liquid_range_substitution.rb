# frozen_string_literal: true

class LiquidRangeSubstitution < Patterns::Calculation
  private
    def result
      node = options[:node]

      "#{node.name.name}: " +
      (replacement_ranges[node.name.name]&.map do |entry|
        node.render(Liquid::Context.new(Hash[node.name.name, entry]))
      end&.join(' - ') || 'N/A')
    end

    def actor
      options[:actor] ||= case subject
                          when Address
                            (subject.virtual_machine || subject.network).actor
                          when AddressPool
                            subject.network.actor
                          else
                            subject.actor
      end
    end

    def replacement_ranges
      {
        'seq' => sequential_range.map { |a| a.to_s.rjust(2, '0') },
        'team_nr' => numbering_range,
        'team_nr_str' => numbering_range&.map { |a| a.to_s.rjust(2, '0') }
      }
    end

    def sequential_range
      case subject
      when VirtualMachine
        [1, subject.custom_instance_count]
      else
        []
      end
    end

    def numbering_range
      if actor.numbering
        actor.numbering[:entries].values_at(0, -1)
      elsif actor.exercise.actors.numbered.size == 1 ## TODO: this seems hacky
        actor.exercise.actors.numbered.first.numbering[:entries].values_at(0, -1)
      end
    end
end
