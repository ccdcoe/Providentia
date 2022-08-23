# frozen_string_literal: true

class ServicePolicy < ApplicationPolicy
  def show?
    super
  end

  def create?
    show? && (admin? || local_admin? || !record.exercise.services_read_only)
  end

  def update?
    create?
  end

  def destroy?
    create?
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
