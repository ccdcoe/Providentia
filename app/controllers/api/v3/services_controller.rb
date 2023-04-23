# frozen_string_literal: true

module API
  module V3
    class ServicesController < APIController
      before_action :get_exercise

      def index
        services = policy_scope(@exercise.services)
        scope = policy_scope(@exercise.customization_specs)
        render json: {
          result: services.map { |service| ServicePresenter.new(service, scope) }
        }
      end

      def show
        service = policy_scope(@exercise.services).find_by(name: params[:id])
        scope = policy_scope(@exercise.customization_specs)
        return render_not_found unless service

        render json: {
          result: ServicePresenter.new(service, scope)
        }
      end
    end
  end
end
