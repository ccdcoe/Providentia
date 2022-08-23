# frozen_string_literal: true

module API
  module V3
    class ServicesController < APIController
      before_action :get_exercise

      def index
        services = policy_scope(@exercise.services)
        render json: {
          result: services.map { |service| ServicePresenter.new(service) }
        }
      end

      def show
        service = policy_scope(@exercise.services).find_by(name: params[:id])
        return render_not_found unless service

        render json: {
          result: ServicePresenter.new(service)
        }
      end
    end
  end
end
