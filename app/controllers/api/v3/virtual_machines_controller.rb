# frozen_string_literal: true

module API
  module V3
    class VirtualMachinesController < APIController
      before_action :get_exercise

      def index
        render json: {
          result: policy_scope(@exercise.virtual_machines).pluck(:name)
        }
      end

      def show
        return render_not_found unless vm

        render json: {
          result: VirtualMachinePresenter.new(vm)
        }
      end

      private
        def vm
          @vm ||= policy_scope(@exercise.virtual_machines).find_by(name: params[:id])
        end
    end
  end
end
