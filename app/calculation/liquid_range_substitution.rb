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

    def numbering_actor
      options[:actor] ||= case subject
                          when Address
                            if subject.virtual_machine
                              vm_numbering_source(subject.virtual_machine)
                            else
                              subject.network.actor
                            end
                          when AddressPool
                            subject.network.actor
                          when VirtualMachine
                            vm_numbering_source(subject)
                          else
                            subject.actor
                          end
    end

    def vm_numbering_source(vm)
      case vm.numbered_by
      when Actor
        vm.numbered_by
      when ActorNumberConfig
        vm.numbered_by.actor
      end || vm.actor
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
      if numbering_actor.number
        [1, numbering_actor.number]
      end
    end
end
