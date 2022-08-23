# frozen_string_literal: true

module API
  module V3
    class CapabilitiesController < APIController
      before_action :get_exercise

      def index
        capabilities = policy_scope(@exercise.capabilities)
        render json: {
          result: capabilities.map { |capability| CapabilityPresenter.new(capability) }
        }
      end
    end
  end
end
