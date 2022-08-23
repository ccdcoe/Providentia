# frozen_string_literal: true

class NetworkPolicy < ApplicationPolicy
  def show?
    admin? || (
      user_has_exercise? && (rt? || local_admin? || !record.team.red?)
    )
  end

  def create?
    admin? || local_admin?
  end

  def update?
    create?
  end

  def edit?
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
        scope.where(team_id: accessible_teams_for_user)
      else
        scope.none
      end
    end
  end
end
