# frozen_string_literal: true

class ActorPolicy < ApplicationPolicy
  def show?
    super
  end

  def create?
    admin? || local_admin?
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
        scope.where(id: accessible_actors_for_user)
      else
        scope.none
      end
    end
  end
end
