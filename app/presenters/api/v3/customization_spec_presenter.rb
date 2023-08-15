# frozen_string_literal: true

module API
  module V3
    class CustomizationSpecPresenter < Struct.new(:spec)
      def as_json(_opts)
        Rails.cache.fetch(cache_key) do
          preload_interfaces
          {
            id: spec.slug,
            spec_name: spec.name.to_url,
            customization_context: spec.mode,
            owner: vm.system_owner&.name,
            description: spec.mode_host? ? vm.description : spec.description,
            role: spec.role,
            actor_id: vm.actor.abbreviation,
            actor_name: vm.actor.name,
            visibility: vm.visibility,
            hardware_cpu: vm.cpu || vm.operating_system&.applied_cpu,
            hardware_ram: vm.ram || vm.operating_system&.applied_ram,
            hardware_primary_disk_size: vm.primary_disk_size || vm.operating_system&.applied_primary_disk_size,
            egress_networks: Current.interfaces_cache[vm.id].filter_map do |nic|
              nic.network.slug if nic.egress?
            end,
            connection_network: Current.interfaces_cache[vm.id]
              .detect(&:connection?)
              &.network
              &.slug,
            tags:,
            capabilities:,
            services:,
            instances:
          }
          .merge(sequence_info)
        end
      end

      private
        def cache_key
          [
            'apiv3',
            vm.cache_key_with_version,
            spec.cache_key_with_version,
            vm.actor&.cache_key_with_version,
            vm.numbered_actor&.cache_key_with_version
          ].compact
        end

        def vm
          spec.virtual_machine
        end

        def host_spec
          vm.host_spec.tap { |spec| spec.virtual_machine = vm } # set manually to avoid extra db call
        end

        def preload_interfaces
          Current.interfaces_cache ||= {}
          Current.interfaces_cache[vm.id] ||= vm.network_interfaces.for_api.load_async
        end

        def tags
          GenerateTags.result_for([
            Current.interfaces_cache[vm.id].detect(&:connection?)&.network,
            vm.operating_system&.path,
            vm.actor,
            vm,
            spec,
            spec.capabilities
          ], spec:).map { |tag_hash| tag_hash[:id] }
        end

        def services
          Service.for_spec(spec).pluck(:slug)
        end

        def instances
          spec.deployable_instances(InstancePresenter).map(&:as_json)
        end

        def capabilities
          spec.capabilities.pluck(:slug).to_a
        end

        def sequence_info
          if vm.custom_instance_count.to_i > 1
            {
              sequence_tag: "sequential_#{spec.slug}".tr('-', '_'),
              sequence_total: vm.custom_instance_count
            }
          else
            {
              sequence_tag: nil,
              sequence_total: nil
            }
          end
        end
    end
  end
end
