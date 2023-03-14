# frozen_string_literal: true

class CloneEnvironment < Patterns::Calculation
  def cloned_environment
    @cloned_environment ||= source_environment.dup.tap do |dest|
      dest.name = options[:name]
      dest.abbreviation = options[:abbreviation]
      dest.slug = nil
    end
  end

  private
    def result
      PaperTrail.request(whodunnit: options[:user]) do
        Exercise.transaction do
          cloned_environment.save!
          cloned_environment.reload

          clone_capabilities
          clone_networks
          clone_services
          clone_vms

          cloned_environment
        end
      end
    end

    def source_environment
      @source_environment ||= Exercise.find(subject)
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
          vm.attributes.merge('exercise_id' => cloned_environment.id, 'created_at' => Time.now, 'updated_at' => Time.now).except('id')
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
          spec.attributes.merge('virtual_machine_id' => vm_id).except('id')
        end
      )

      combined_data = {
        capabilities: [],
        services: []
      }
      current_specs.zip(new_specs).each_with_object(combined_data) do |(spec, new_spec), memo|
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

        cloned_environment
          .services
          .where(name: spec.services.pluck(:name))
          .pluck(:id)
          .each do |new_service_id|
            memo[:services] << {
              'service_id' => ActiveRecord::Base.connection.quote(new_service_id),
              'customization_spec_id' => ActiveRecord::Base.connection.quote(new_spec['id'])
            }
          end
      end

      if combined_data[:capabilities].any?
        ActiveRecord::Base.connection.execute <<-SQL
          INSERT INTO capabilities_customization_specs (#{combined_data[:capabilities].first.keys.join(",")}) VALUES
          #{combined_data[:capabilities].map(&:values).map { |values| "(#{values.join(",")})" }.join(", ")}
        SQL
      end

      if combined_data[:services].any?
        ActiveRecord::Base.connection.execute <<-SQL
          INSERT INTO customization_specs_services (#{combined_data[:services].first.keys.join(",")}) VALUES
          #{combined_data[:services].map(&:values).map { |values| "(#{values.join(",")})" }.join(", ")}
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
        if service.service_checks.any?
          ServiceCheck.insert_all(
            service.service_checks.map do |service_check|
              service_check.attributes.merge(
                'service_id' => new_service_id['id'],
                'network_id' => find_network_in_cloned_environment(service_check.network).id
              ).except('id')
            end
          )
        end

        if service.special_checks.any?
          SpecialCheck.insert_all(
            service.special_checks.map do |special_check|
              special_check.attributes.merge(
                'service_id' => new_service_id['id'],
                'network_id' => find_network_in_cloned_environment(special_check.network).id
              ).except('id')
            end
          )
        end
      end
    end

    def find_network_in_cloned_environment(source_net)
      (@cached_networks ||= cloned_environment.networks.group_by(&:slug)).dig(source_net.slug, 0)
    end
end
