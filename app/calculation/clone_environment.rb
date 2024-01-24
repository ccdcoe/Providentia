# frozen_string_literal: true

class CloneEnvironment < Patterns::Calculation
  def cloned_environment
    @cloned_environment ||= begin
      Exercise.insert(
        source_environment.attributes.merge(
          name: options[:name],
          abbreviation: options[:abbreviation],
          slug: nil
        ).except('id')
      ).then { Exercise.find(_1.to_a.dig(0, 'id')) }
    end
  end

  private
    def result
      PaperTrail.request(whodunnit: options[:user]) do
        Exercise.transaction do
          cloned_environment.save!
          cloned_environment.reload

          clone_actors(source_environment.actors.arrange)
          clone_capabilities
          clone_networks
          clone_vms
          clone_services

          cloned_environment
        end
      end
    end

    def source_environment
      @source_environment ||= Exercise.find(subject)
    end

    def clone_actors(tree, parent: nil)
      tree.each do |node, children|
        new_actor = cloned_environment.actors.create(
          node.attributes.merge(
            'exercise_id' => cloned_environment.id,
            'created_at' => Time.now,
            'updated_at' => Time.now,
            'parent' => parent
          ).except('id')
        )

        ActorNumberConfig.insert_all(
          node.actor_number_configs.map do |config|
            config.attributes.merge('actor_id' => new_actor.id).except('id')
          end
        )

        clone_actors(children, parent: new_actor)
      end
    end

    def clone_networks
      source_environment.networks.each do |network|
        new_network = Network.insert(
          network.attributes.merge('exercise_id' => cloned_environment.id, 'created_at' => Time.now, 'updated_at' => Time.now).except('id')
        )
        next unless network.address_pools.any?
        AddressPool.insert_all(
          network.address_pools.map do |pool|
            pool.attributes.merge('network_id' => new_network.to_a.dig(0, 'id')).except('id')
          end
        )
      end
    end

    def clone_vms
      source_environment.virtual_machines.includes(network_interfaces: [:addresses]).each do |vm|
        new_vm = VirtualMachine.insert(
          vm.attributes.merge(
            'exercise_id' => cloned_environment.id,
            'actor_id' => find_actor_in_cloned_environment(vm.actor).id,
            'numbered_by_id' => find_numerable_in_cloned_environment(vm.numbered_by)&.id,
            'created_at' => Time.now,
            'updated_at' => Time.now
          ).except('id')
        )

        clone_customization_specs(
          current_specs: vm.customization_specs.sort,
          vm_id: new_vm.to_a.dig(0, 'id')
        )
        clone_network_interfaces(
          current_nics: vm.network_interfaces.sort,
          vm_id: new_vm.to_a.dig(0, 'id')
        )
      end
    end

    def clone_customization_specs(current_specs:, vm_id:)
      new_specs = CustomizationSpec.insert_all(
        current_specs.map do |spec|
          spec.attributes.merge('virtual_machine_id' => vm_id).except('id', 'tag_list')
        end
      )

      combined_data = {
        capabilities: []
      }
      current_specs.zip(new_specs).each_with_object(combined_data) do |(spec, new_spec), memo|
        CustomizationSpec.find(new_spec['id']).update(tag_list: spec.tag_list.join(', '))
        cloned_environment
          .capabilities
          .where(slug: spec.capabilities.pluck(:slug))
          .pluck(:id)
          .each do |new_cap_id|
            memo[:capabilities] << {
              'capability_id' => ActiveRecord::Base.connection.quote(new_cap_id),
              'customization_spec_id' => ActiveRecord::Base.connection.quote(new_spec['id'])
            }
          end
      end

      if combined_data[:capabilities].any?
        ActiveRecord::Base.connection.execute <<-SQL
          INSERT INTO capabilities_customization_specs (#{ActiveRecord::Base.connection.quote(combined_data[:capabilities].first.keys.join(","))}) VALUES
          #{ActiveRecord::Base.connection.quote(combined_data[:capabilities].map(&:values).map { |values| "(#{values.join(",")})" }.join(", "))}
        SQL
      end
    end

    def clone_network_interfaces(current_nics:, vm_id:)
      return if current_nics.empty?
      new_nic_ids = NetworkInterface.insert_all(
        current_nics.map do |nic|
          nic.attributes.merge(
            'virtual_machine_id' => vm_id,
            'network_id' => find_network_in_cloned_environment(nic.network).id
          ).except('id')
        end,
        returning: [:id, :network_id]
      )


      Address.insert_all(
        current_nics.zip(new_nic_ids).flat_map do |nic, new_record|
          return [] if nic.addresses.empty?
          nic.addresses.map do |address|
            address.attributes.merge(
              'network_interface_id' => new_record['id'],
              'address_pool_id' => AddressPool.find_by(network_id: new_record['network_id'], slug: address.address_pool&.slug)&.id
            ).except('id')
          end
        end
      )
    end

    def clone_capabilities
      return if source_environment.capabilities.empty?
      Capability.insert_all(
        source_environment.capabilities.map do |cap|
          cap.attributes.merge('exercise_id' => cloned_environment.id).except('id')
        end
      )
    end

    def clone_services
      current_services = source_environment.services.to_a
      return if current_services.empty?
      new_service_ids = Service.insert_all(
        current_services.map do |service|
          service.attributes.merge('exercise_id' => cloned_environment.id).except('id')
        end
      )

      current_services.zip(new_service_ids).each do |service, new_service_id|
        if service.service_subjects.any?
          ServiceSubject.insert_all(
            service.service_subjects.map do |subject|
              subject.attributes.merge(
                'service_id' => new_service_id['id'],
                'match_conditions' => subject.match_conditions.map do |condition|
                  case condition.matcher_type
                  when 'CustomizationSpec'
                    condition.matcher_id = find_spec_in_cloned_environment(
                      source_environment.customization_specs.find(condition.matcher_id)
                    ).id
                  when 'Capability'
                    condition.matcher_id = find_capability_in_cloned_environment(
                      source_environment.capabilities.find(condition.matcher_id)
                    ).id
                  when 'Network'
                    condition.matcher_id = find_network_in_cloned_environment(
                      source_environment.networks.find(condition.matcher_id)
                    ).id
                  when 'Actor'
                    condition.matcher_id = find_actor_in_cloned_environment(
                      source_environment.actors.find(condition.matcher_id)
                    ).id
                  end
                  condition
                end
              ).except('id')
            end
          )
        end

        if service.checks.any?
          Check.insert_all(
            service.checks.map do |check|
              check.attributes.merge(
                'service_id' => new_service_id['id'],
                'source_id' => case check.source
                               when Network
                                 find_network_in_cloned_environment(check.source).id
                               when CustomizationSpec
                                 find_spec_in_cloned_environment(check.source).id
                               else
                                 check.source_id
                               end,
                'destination_id' => case check.destination
                                    when Network
                                      find_network_in_cloned_environment(check.destination).id
                                    when CustomizationSpec
                                      find_spec_in_cloned_environment(check.destination).id
                                    else
                                      check.destination_id
                                    end
              ).except('id')
            end
          )
        end
      end
    end

    def find_network_in_cloned_environment(source_net)
      (@cached_networks ||= cloned_environment.networks.group_by(&:slug)).dig(source_net.slug, 0)
    end

    def find_actor_in_cloned_environment(source_actor)
      cloned_environment.actors.detect { _1.abbreviation == source_actor.abbreviation }
    end

    def find_spec_in_cloned_environment(source_spec)
      cloned_environment.customization_specs.detect { _1.slug == source_spec.slug }
    end

    def find_capability_in_cloned_environment(source_cap)
      cloned_environment.capabilities.detect { _1.abbreviation == source_cap.abbreviation }
    end

    def find_numerable_in_cloned_environment(source_numberable)
      case source_numberable
      when Actor
        find_actor_in_cloned_environment(source_numberable)
      when ActorNumberConfig
        find_actor_in_cloned_environment(source_numberable.actor)
          .actor_number_configs.detect { _1.name == source_numberable.name }
      end
    end
end
