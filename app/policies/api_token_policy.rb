# frozen_string_literal: true

class APITokenPolicy < ApplicationPolicy
  def create?
    true
  end

  def show?
    user_owns_api_token?
  end

  def update?
    user_owns_api_token?
  end

  def destroy?
    user_owns_api_token?
  end

  private
    def user_owns_api_token?
      record.user_id == user.id
    end

    class Scope < Scope
      def resolve
        return scope.none unless user

        scope.where(user_id: user.id)
      end
    end
end
