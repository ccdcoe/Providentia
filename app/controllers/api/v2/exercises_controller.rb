# frozen_string_literal: true

module API
  module V2
    class ExercisesController < APIController
      include ActionController::ImplicitRender
      helper :api

      helper_method :virtual_machines, :machine_instances, :vm_cache_key,
        :network_cache_key, :os_cache_key

      before_action :get_exercise

      def show
        return render json: {
          error: 'Not found',
          code: 404
        }, status: 404 unless @exercise
        authorize @exercise
      end

      private
        def get_exercise
          @exercise = Exercise.find_by(abbreviation: params[:id])
        end

        def vm_cache_key
          "vm_#{policy_scope(@exercise.virtual_machines).cache_key_with_version}"
        end

        def network_cache_key
          "net_#{policy_scope(@exercise.networks).cache_key_with_version}"
        end

        def virtual_machines
          @virtual_machines ||= policy_scope(@exercise.virtual_machines)
            .includes(
              {
                network_interfaces: [
                  {
                    network: [:exercise]
                  }
                ],
              },
              {
                host_spec: [
                  { virtual_machine: [:exercise] },
                  {
                    services: {
                      service_checks: [],
                      special_checks: [:network]
                    },
                  },
                ]
              },
              { addresses: [:address_pool] },
              :operating_system,
              :connection_nic,
              :system_owner,
              :networks,
              :team,
            )
        end

        def machine_instances
          virtual_machines.flat_map { |vm| vm.host_spec.deployable_instances }
        end
    end
  end
end
