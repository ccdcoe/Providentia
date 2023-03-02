# frozen_string_literal: true

class VirtualMachinePolicy < ApplicationPolicy
  def show?
    admin? || (
      user_has_exercise? && (rt? || local_admin? || vm_is_not_red?)
    )
  end

  def create?
    show?
  end

  def update?
    show?
  end

  def destroy?
    show?
  end

  private
    def vm_is_not_red?
      return unless record.is_a?(VirtualMachine)

      !record.team&.red?
    end

    class Scope < Scope
      def resolve
        if user.admin?
          scope.all
        elsif exercises_for_context.any?
          scope
            .where(exercises_for_context.map do |ex|
              "(exercise_id = #{ActiveRecord::Base.connection.quote(ex.to_i)} AND team_id IN (#{accessible_teams_for_user(ex).map { |a| ActiveRecord::Base.connection.quote(a) }.join(', ')}))"
            end
            .join(' OR '))
        else
          scope.none
        end
      end
    end
end
