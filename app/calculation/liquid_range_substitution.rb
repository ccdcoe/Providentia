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
                            if subject.virtual_machine
                              case subject.virtual_machine.numbered_by
                              when Actor
                                subject.virtual_machine.numbered_by
                              else
                                subject.virtual_machine.numbered_by.actor
                              end || subject.virtual_machine.actor
                            else
                              subject.network.actor
                            end
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
      if actor.number
        [1, actor.number]
      end
    end
end
