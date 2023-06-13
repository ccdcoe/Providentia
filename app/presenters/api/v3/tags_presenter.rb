# frozen_string_literal: true

module API
  module V3
    class TagsPresenter < Struct.new(:exercise, :scope)
      def as_json(_opts)
        actor_tags + os_tags + zone_tags + capability_tags + spec_tags
      end

      private
        def network_scope
          # @network_scope ||= Pundit.policy_scope(scope, exercise.networks)
          # temporarily show all networks in API
          @network_scope ||= exercise.networks
        end

        def spec_scope
          @spec_scope ||= Pundit.policy_scope(scope, exercise.customization_specs)
        end

        def actor_scope
          @actor_scope ||= Pundit.policy_scope(scope, exercise.actors)
        end

        def actor_tags
          Rails.cache.fetch(['apiv3', exercise.cache_key_with_version, 'actors', actor_scope.cache_key_with_version]) do
            GenerateTags.result_for(actor_scope.all)
          end
        end

        def os_tags
          Rails.cache.fetch(['apiv3', exercise.cache_key_with_version, 'os', OperatingSystem.all.cache_key_with_version]) do
            GenerateTags.result_for(OperatingSystem.all)
          end
        end

        def zone_tags
          Rails.cache.fetch(['apiv3', exercise.cache_key_with_version, 'zone', network_scope.cache_key_with_version]) do
            GenerateTags.result_for(network_scope.all)
          end
        end

        def capability_tags
          Rails.cache.fetch(['apiv3', exercise.cache_key_with_version, 'capability_list', exercise.capabilities.cache_key_with_version]) do
            GenerateTags.result_for(exercise.capabilities.all)
          end
        end

        def spec_tags
          Rails.cache.fetch(['apiv3', exercise.cache_key_with_version, 'spec_tags', spec_scope.cache_key_with_version]) do
            GenerateTags.result_for(spec_scope.all).uniq
          end
        end
    end
  end
end
