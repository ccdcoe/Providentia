# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def create?
    false
  end

  private
    def admin?
      false
    end

    class Scope < Scope
      def resolve
        scope.for_exercise(exercise)
      end
    end
end
