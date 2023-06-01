# frozen_string_literal: true

module API
  module V3
    class CustomizationSpecPresenter < Struct.new(:spec)
      def as_json(_opts)
        Rails.cache.fetch(['apiv3', vm.cache_key_with_version, spec.cache_key_with_version]) do
          preload_interfaces
          {
            id: spec.slug,
            parent_id:,
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

      def sequential_group
        return unless vm.custom_instance_count.to_i > 1
        "sequential_#{spec.slug}".tr('-', '_')
      end

      private
        def vm
          spec.virtual_machine
        end

        def host_spec
          vm.host_spec.tap { |spec| spec.virtual_machine = vm } # set manually to avoid extra db call
        end

        def parent_id
          host_spec.slug unless spec.mode_host?
        end

        def preload_interfaces
          Current.interfaces_cache ||= {}
          Current.interfaces_cache[vm.id] ||= vm.network_interfaces.for_api.load_async
        end

        def tags
          [
            sequential_group,
            vm.connection_nic&.api_short_name,
            (vm.operating_system&.path || []).map(&:api_short_name),
            vm.actor.api_short_name,
            vm.actor.as_team_api.dig(:id),
            ("#{vm.actor.api_short_name}_#{vm.numbered_actor.abbreviation}_numbered" if vm.numbered_actor && vm.actor != vm.numbered_actor),
            ('customization_container' if spec.mode_container?),
            spec.capabilities.map(&:api_short_name)
          ].flatten.compact
        end

        def services
          Service.for_spec(spec).pluck(:slug)
        end

        def instances
          spec.deployable_instances(InstancePresenter).map(&:as_json)
        end

        def capabilities
          [] + spec.capabilities.pluck(:slug).to_a + vm.connection_nic&.network&.capabilities&.pluck(:slug).to_a
        end

        def sequence_info
          {
            sequence_tag: sequential_group,
            sequence_total: vm.custom_instance_count.to_i > 1 ? vm.custom_instance_count : nil
          }
        end
    end
  end
end
