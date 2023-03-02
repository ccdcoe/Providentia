# frozen_string_literal: true

module API
  module V3
    class NetworksController < APIController
      before_action :get_exercise

      def index
        networks = policy_scope(@exercise.networks)
        render json: {
          result: networks.map { |network| NetworkPresenter.new(network) }
        }
      end
    end
  end
end
