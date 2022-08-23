# frozen_string_literal: true

class APITokensController < ApplicationController
  before_action :get_api_token, only: %i[destroy]

  def index
    @api_tokens = policy_scope(APIToken)
  end

  def new
    @api_token = current_user.api_tokens.build
    authorize @api_token
  end

  def create
    @api_token = current_user.api_tokens.build(api_token_params)
    authorize(@api_token).save!
  end

  def destroy
    authorize @api_token
    @api_token.destroy

    redirect_to @api_token, notice: "#{APIToken.model_name.human} was successfully deleted."
  end

  private
    def api_token_params
      params.require(:api_token).permit(:name)
    end

    def get_api_token
      @api_token = APIToken.find(params[:id])
    end
end
