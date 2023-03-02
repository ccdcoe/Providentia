# frozen_string_literal: true

module API
  module V3
    class InventoriesController < APIController
      before_action :get_exercise

      def show
        hosts = policy_scope(@exercise.customization_specs)
          .includes(
            {
              virtual_machine: [
                :system_owner,
                :team,
                :operating_system,
                :host_spec,
                :exercise,
                connection_nic: [:network, { addresses: [:address_pool] }]
              ]
            },
            :capabilities_customizationspecs,
            :capabilities,
            :customizationspecs_services,
            {
              services: [
                { service_checks: [:network] },
                { special_checks: [:network] }
              ]
            }
          )
        render json: {
          result: hosts.map { |spec| CustomizationSpecPresenter.new(spec) }
        }
      end
    end
  end
end
