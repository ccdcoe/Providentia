# frozen_string_literal: true

module API
  module V3
    class NetworksController < APIController
      before_action :get_exercise

      def index
        render json: {
          result: policy_scope(@exercise.networks).pluck(:slug)
        }
      end

      def show
        return render_not_found unless network

        render json: {
          result: NetworkPresenter.new(network)
        }
      end

      private
        def network
          @network ||= policy_scope(@exercise.networks).find_by(slug: params[:id])
        end
    end
  end
end
