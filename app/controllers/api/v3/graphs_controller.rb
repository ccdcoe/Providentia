# frozen_string_literal: true

module API
  module V3
    class GraphsController < APIController
      before_action :get_exercise

      def show
        render json: {
          result: Rails.cache.fetch(['apiv3', vm_scope, 'network_graph']) do
            NetworkMapGraphSerializer.result_for(graph)
          end
        }
      end

      private
        def vm_scope
          policy_scope(@exercise.virtual_machines)
            .includes(connection_nic: [{ network: [:team] }, :virtual_machine])
            .includes(:team)
        end

        def graph
          ExerciseGraphGenerator.result_for(vm_scope, { skip_single_hop_networks: true })
        end
    end
  end
end
