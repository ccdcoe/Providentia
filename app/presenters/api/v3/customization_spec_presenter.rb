# frozen_string_literal: true

module API
  module V3
    class CustomizationSpecPresenter < Struct.new(:spec)
      delegate :team,
        :deploy_mode, :deploy_mode_single?,
        to: :vm

      def as_json(_opts)
        Rails.cache.fetch(['apiv3', vm, spec]) do
          preload_interfaces
          {
            id: spec.slug,
            parent_id:,
            customization_context: spec.mode,
            owner: vm.system_owner&.name,
            description: spec.mode_host? ? vm.description : spec.description,
            role: spec.role,
            team_name: vm.team.name.downcase,
            bt_visible: vm.api_bt_visible,
            hardware_cpu: vm.cpu || vm.operating_system&.applied_cpu,
            hardware_ram: vm.ram || vm.operating_system&.applied_ram,
            hardware_primary_disk_size: vm.primary_disk_size || vm.operating_system&.applied_primary_disk_size,
            tags:,
            capabilities:,
            services:
          }
          .merge(sequence_info)
          .merge({ instances: })
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
            team.api_short_name,
            ("#{team.api_short_name}_#{deploy_mode}_numbered" if !deploy_mode_single? && !team.blue?),
            ('customization_container' if spec.mode_container?),
            spec.capabilities.map(&:api_short_name)
          ].flatten.compact
        end

        def services
          spec.services.pluck(:name)
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
