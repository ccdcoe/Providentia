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
      elsif exercise_ids_for_context.any?
        scope
          .where(exercise_ids_for_context.map do |ex|
            "(exercise_id = #{ActiveRecord::Base.connection.quote(ex.to_i)} AND team_id IN (#{accessible_teams_for_user(ex).map { |a| ActiveRecord::Base.connection.quote(a) }.join(', ')}))"
          end
          .join(' OR '))
      else
        scope.none
      end
    end
  end
end
