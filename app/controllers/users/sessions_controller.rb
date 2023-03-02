
# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  private
    def after_sign_out_path_for(_)
      '/users/auth/sso/logout'
    end
end
