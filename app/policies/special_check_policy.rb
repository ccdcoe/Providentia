# frozen_string_literal: true

class SpecialCheckPolicy < ApplicationPolicy
  def show?
    super
  end

  def create?
    show? && (admin? || !record.exercise.services_read_only)
  end

  def update?
    show? && (admin? || !record.exercise.services_read_only)
  end

  def destroy?
    show? && (admin? || !record.exercise.services_read_only)
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
