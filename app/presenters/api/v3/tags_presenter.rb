# frozen_string_literal: true

module API
  module V3
    class TagsPresenter < Struct.new(:exercise, :scope)
      def as_json(_opts)
        actor_tags + os_tags + zone_tags + type_tags + sequential_tags + numbered_tags + capability_tags
      end

      private
        def network_scope
          # @network_scope ||= Pundit.policy_scope(scope, exercise.networks)
          # temporarily show all networks in API
          @network_scope ||= exercise.networks
        end

        def vm_scope
          @vm_scope ||= Pundit.policy_scope(scope, exercise.virtual_machines)
        end

        def actor_scope
          @actor_scope ||= Pundit.policy_scope(scope, exercise.actors)
        end

        def actor_tags
          Rails.cache.fetch(['apiv3', exercise.cache_key_with_version, 'actors', actor_scope.cache_key_with_version]) do
            actor_scope.flat_map do |actor|
              [
                {
                  id: actor.api_short_name,
                  name: actor.name,
                  config_map: {},
                  children: [],
                },
                actor.as_team_api
              ].compact
            end
          end
        end

        def os_tags
          Rails.cache.fetch(['apiv3', exercise.cache_key_with_version, 'os', OperatingSystem.all.cache_key_with_version]) do
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
          Rails.cache.fetch(['apiv3', exercise.cache_key_with_version, 'zone', network_scope.cache_key_with_version]) do
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

        def type_tags
          [{ id: 'customization_container', name: 'customization_container', config_map: {}, children: [] }]
        end

        def sequential_tags
          Rails.cache.fetch(['apiv3', exercise.cache_key_with_version, 'sequential', vm_scope.cache_key_with_version]) do
            vm_scope
              .where.not(custom_instance_count: nil)
              .flat_map(&:customization_specs)
              .map { |spec| CustomizationSpecPresenter.new(spec) }
              .map(&:sequential_group)
              .uniq
              .compact
              .map do |group_name|
                { id: group_name, name: group_name, config_map: {}, children: [] }
              end
          end
        end

        def numbered_tags
          Rails.cache.fetch(['apiv3', exercise.cache_key_with_version, 'numbered', vm_scope.cache_key_with_version]) do
            vm_scope
              .select(&:numbered_actor)
              .group_by { |instance| [instance.actor, instance.numbered_actor] }
              .filter_map do |group, instances|
                actor, numbered_actor = group
                next if actor == numbered_actor
                {
                  id: "#{actor.api_short_name}_#{numbered_actor.abbreviation}_numbered",
                  name: "#{actor.api_short_name}_#{numbered_actor.abbreviation}_numbered",
                  config_map: {},
                  children: [],
                }
              end
          end
        end

        def capability_tags
          Rails.cache.fetch(['apiv3', exercise.cache_key_with_version, 'capability_list', exercise.capabilities.cache_key_with_version]) do
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
