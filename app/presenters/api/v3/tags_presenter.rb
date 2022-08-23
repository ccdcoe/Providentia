# frozen_string_literal: true

module API
  module V3
    class TagsPresenter < Struct.new(:exercise, :scope)
      def as_json(_opts)
        team_tags + os_tags + zone_tags + sequential_tags + numbered_tags + capability_tags
      end

      private
        def network_scope
          @network_scope ||= Pundit.policy_scope(scope, exercise.networks)
        end

        def vm_scope
          @vm_scope ||= Pundit.policy_scope(scope, exercise.virtual_machines)
        end

        def team_tags
          Rails.cache.fetch(['apiv3', exercise, 'tags', Team.all.cache_key_with_version]) do
            Team.all.map do |team|
              {
                id: team.api_short_name,
                name: team.name,
                config_map: { team_color: team.name },
                children: [],
              }
            end
          end
        end

        def os_tags
          Rails.cache.fetch(['apiv3', exercise, 'os', OperatingSystem.all.cache_key_with_version]) do
            OperatingSystem.all.map do |os|
              {
                id: os.api_short_name,
                name: os.name,
                config_map: {},
                children: os.children.map(&:api_short_name)
              }
            end
          end
        end

        def zone_tags
          Rails.cache.fetch(['apiv3', exercise, 'zone', network_scope.cache_key_with_version]) do
            network_scope.map do |network|
              {
                id: network.api_short_name,
                name: network.name,
                config_map: {
                  domain: network.full_domain
                },
                children: []
              }
            end
          end
        end

        def sequential_tags
          Rails.cache.fetch(['apiv3', exercise, 'sequential', vm_scope.cache_key_with_version]) do
            vm_scope
              .map { |vm| VirtualMachinePresenter.new(vm) }
              .map(&:sequential_group)
              .uniq
              .compact
              .map do |group_name|
                { id: group_name, name: group_name, config_map: {}, children: [] }
              end
          end
        end

        def numbered_tags
          Rails.cache.fetch(['apiv3', exercise, 'numbered', vm_scope.cache_key_with_version]) do
            vm_scope
              .reject(&:deploy_mode_single?)
              .group_by { |instance| [instance.team, instance.deploy_mode] }
              .filter_map do |group, instances|
                team, mode = group
                next if team.blue?
                {
                  id: "#{team.api_short_name}_#{mode}_numbered",
                  name: "#{team.api_short_name}_#{mode}_numbered",
                  config_map: {},
                  children: [],
                }
              end
          end
        end

        def capability_tags
          Rails.cache.fetch(['apiv3', exercise, 'capability_list', exercise.capabilities]) do
            exercise.capabilities.map do |cap|
              {
                id: cap.api_short_name,
                name: cap.name,
                config_map: {},
                children: [],
              }
            end
          end
        end
    end
  end
end
