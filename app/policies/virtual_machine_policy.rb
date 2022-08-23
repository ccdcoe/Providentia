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
        elsif user.accessible_exercises[exercise.id.to_s]
          scope.where(team_id: accessible_teams_for_user)
        else
          scope.none
        end
      end
    end
end
