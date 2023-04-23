# frozen_string_literal: true

class ServiceSubjectPolicy < ApplicationPolicy
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
      ServicePolicy.new(user_context, record.service)
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
