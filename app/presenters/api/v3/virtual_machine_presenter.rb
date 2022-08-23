# frozen_string_literal: true

module API
  module V3
    class VirtualMachinePresenter < Struct.new(:vm)
      delegate :team,
        :operating_system,
        :deploy_mode, :deploy_mode_single?,
        to: :vm

      def as_json(_opts)
        Rails.cache.fetch(['apiv3', vm]) do
          {
            id: vm.name,
            owner: vm.system_owner&.name,
            description: vm.description,
            role: vm.role.presence || vm.name,
            team_name: vm.team.name.downcase,
            bt_visible: vm.api_bt_visible,
            hardware_cpu: vm.cpu || vm.operating_system&.applied_cpu,
            hardware_ram: vm.ram || vm.operating_system&.applied_ram,
            hardware_primary_disk_size: vm.primary_disk_size || vm.operating_system&.applied_primary_disk_size,
            tags: tags,
            capabilities: capabilities,
            services: services
          }
          .merge(sequence_info)
          .merge({ instances: instances })
        end
      end

      def sequential_group
        return unless vm.custom_instance_count.to_i > 1
        "sequential_#{vm.name}".tr('-', '_')
      end

      private
        def tags
          [
            sequential_group,
            vm.connection_nic&.api_short_name,
            (operating_system&.path || []).map(&:api_short_name),
            team.api_short_name,
            ("#{team.api_short_name}_#{deploy_mode}_numbered" if !deploy_mode_single? && !team.blue?),
            vm.capabilities.map(&:api_short_name)
          ].flatten.compact
        end

        def services
          vm.services.map(&:name)
        end

        def instances
          vm.deployable_instances(VmInstancePresenter).map(&:as_json)
        end

        def capabilities
          Capability.where(
            id: vm.capability_ids + vm.connection_nic&.network&.capability_ids.to_a
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
