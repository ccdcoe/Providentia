
# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  private
    def respond_to_on_destroy
      respond_to do |format|
        format.all { head :no_content }
        format.any(*navigational_formats) { redirect_to after_sign_out_path_for(resource_name), status: 303 }
      end
    end

    def after_sign_out_path_for(_)
      new_user_session_path
    end
end
