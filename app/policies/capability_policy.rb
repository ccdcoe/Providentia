# frozen_string_literal: true

class CapabilityPolicy < ApplicationPolicy
  def show?
    admin? || user_has_exercise?
  end

  def create?
    show?
  end

  def update?
    show?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.accessible_exercises[exercise.id.to_s]
        scope.where(exercise_id: exercise.id)
      else
        scope.none
      end
    end
  end
end
