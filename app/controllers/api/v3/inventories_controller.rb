# frozen_string_literal: true

module API
  module V3
    class InventoriesController < APIController
      before_action :get_exercise

      def show
        scope = policy_scope(@exercise.customization_specs).for_api
        render json: {
          result: Rails.cache.fetch([
            'apiv3',
            @exercise.cache_key_with_version,
            scope,
            policy_scope(@exercise.virtual_machines),
            'inventory'
          ]) do
            scope.map { |spec| CustomizationSpecPresenter.new(spec) }
          end
        }
      end
    end
  end
end
