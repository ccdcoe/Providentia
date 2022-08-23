# frozen_string_literal: true

class ExercisePolicy < ApplicationPolicy
  def show?
    admin? || user_has_exercise?
  end

  class Scope < Scope
    def resolve
      return scope.none unless user

      if user.admin?
        scope.all
      elsif user.accessible_exercises.present?
        scope.where(id: user.accessible_exercises.keys)
      else
        scope.none
      end
    end
  end
end
