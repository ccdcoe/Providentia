# frozen_string_literal: true

class CustomizationSpecPolicy < ApplicationPolicy
  def show?
    parent_policy.show?
  end

  def create?
    parent_policy.create?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end

  private
    def parent_policy
      VirtualMachinePolicy.new(user_context, record.virtual_machine)
    end

    class Scope < Scope
      def resolve
        if user.admin?
          scope.all
        elsif user.accessible_exercises[exercise.id.to_s]
          scope.joins(:virtual_machine).where(virtual_machine: { exercise: exercise, team_id: accessible_teams_for_user(exercise.id) })
        else
          scope.none
        end
      end
    end
end
