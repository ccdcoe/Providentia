# frozen_string_literal: true

module API
  module V3
    class CustomizationSpecPresenter < Struct.new(:spec)
      delegate :team,
        :operating_system,
        :deploy_mode, :deploy_mode_single?,
        to: :vm

      def as_json(_opts)
        Rails.cache.fetch(['apiv3', vm, spec]) do
          {
            id: spec.slug,
            customization_context: spec.mode,
            owner: vm.system_owner&.name,
            description: vm.description,
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

        def tags
          [
            sequential_group,
            vm.connection_nic&.api_short_name,
            (operating_system&.path || []).map(&:api_short_name),
            team.api_short_name,
            ("#{team.api_short_name}_#{deploy_mode}_numbered" if !deploy_mode_single? && !team.blue?),
            ('customization_container' if spec.mode_container?),
            spec.capabilities.map(&:api_short_name)
          ].flatten.compact
        end

        def services
          spec.services.map(&:name)
        end

        def instances
          spec.deployable_instances(InstancePresenter).map(&:as_json)
        end

        def capabilities
          Capability.where(
            id: spec.capability_ids + vm.connection_nic&.network&.capability_ids.to_a
          ).pluck(:slug)
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
