# frozen_string_literal: true

class GenerateTags < Patterns::Calculation
  private
    def result
      case subject
      when OperatingSystem
        os_result
      when Actor
        actor_result
      when Network
        network_result
      when VirtualMachine
        virtual_machine_result || []
      when CustomizationSpec
        spec_result
      when Capability
        capability_result
      when API::V3::InstancePresenter
        instance_result || []
      when Enumerable
        subject.map { |item| self.class.result_for(item, options) }.flatten
      end.flatten.compact
    end

    def os_result
      [{
        id: subject.api_short_name,
        name: subject.name,
        config_map: {},
        children: subject.children.map(&:api_short_name)
      }]
    end

    def actor_result
      [
        {
          id: subject.api_short_name,
          name: subject.name,
          config_map: {},
          children: numbered_actors.map { |h| h[:id] },
        },
        subject.as_team_api,
        numbered_actors,
        actors_as_numbered_for_vms
      ].reject(&:blank?)
    end

    def numbered_actors
      return [] if options[:spec] || !subject.numbering
      subject.numbering[:entries].map do |number|
        {
          id: "#{subject.api_short_name}_t#{number.to_s.rjust(2, "0")}",
          name: "#{subject.name} number #{number}",
          config_map: {},
          children: [],
        }
      end
    end

    def actors_as_numbered_for_vms
      return if options[:spec] # this is only needed if "overall" tags list is generated, not for specific spec
      subject
        .numbered_virtual_machines
        .map(&:actor)
        .uniq
        .excluding(subject)
        .map do |vm_actor|
          children = subject.numbering[:entries].map do |number|
            id = "#{vm_actor.api_short_name}_#{subject.abbreviation}_numbered_t#{number.to_s.rjust(2, "0")}"
            {
              id:,
              name: "#{vm_actor.name}, numbered by #{subject.name} - number #{number}",
              config_map: {},
              children: [],
            }
          end

          [{
            id: "#{vm_actor.api_short_name}_#{subject.abbreviation}_numbered",
            name: "#{vm_actor.name}, numbered by #{subject.name}",
            config_map: {},
            children: children.map { |entry| entry[:id] },
          }] + children
        end
    end

    def network_result
      [{
        id: subject.api_short_name,
        name: subject.name,
        config_map: {
          domain: subject.full_domain
        },
        children: []
      }]
    end

    def virtual_machine_result
      return unless subject.numbered_actor && subject.actor != subject.numbered_actor
      id = "#{subject.actor.api_short_name}_#{subject.numbered_actor.abbreviation}_numbered"
      [{
        id:,
        name: id,
        config_map: {},
        children: []
      }]
    end

    def spec_result
      many_items = subject.virtual_machine.custom_instance_count.to_i > 1 || subject.virtual_machine.numbered_actor
      [
        ({ id: subject.slug.tr('-', '_'), name: "All instances of #{subject.slug}", config_map: {}, children: [] } if many_items),
        ({ id: 'customization_container', name: 'customization_container', config_map: {}, children: [] } if subject.mode_container?),
      ]
    end

    def capability_result
      [{
        id: "capability_#{subject.slug}".downcase.tr('-', '_'),
        name: subject.name,
        config_map: {},
        children: [],
      }]
    end

    def instance_result
      return if !subject.team_number

      actor = subject.spec.virtual_machine.actor
      nr_actor = subject.spec.virtual_machine.numbered_actor
      if actor == nr_actor
        [{
          id: "#{actor.api_short_name}_t#{subject.team_number.to_s.rjust(2, "0")}",
          name: "#{actor.name} number #{subject.team_number}",
          config_map: {},
          children: [],
        }]
      else
        [{
          id: "#{actor.api_short_name}_#{nr_actor.abbreviation}_numbered_t#{subject.team_number.to_s.rjust(2, "0")}",
          name: "#{actor.name}, numbered by #{nr_actor.name} - number #{subject.team_number}",
          config_map: {},
          children: [],
        }]
      end
    end
end
