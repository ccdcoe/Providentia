# frozen_string_literal: true

module API
  module V3
    class InventoriesController < APIController
      before_action :get_exercise

      def show
        hosts = policy_scope(@exercise.virtual_machines)
        render json: {
          result: hosts.map { |vm| VirtualMachinePresenter.new(vm) }
        }
      end
    end
  end
end
