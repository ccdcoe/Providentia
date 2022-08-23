# frozen_string_literal: true

module API
  module V3
    class TagsController < APIController
      before_action :get_exercise

      def index
        render json: { result: TagsPresenter.new(@exercise, pundit_user) }
      end
    end
  end
end
