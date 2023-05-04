# frozen_string_literal: true

class CheckPolicy < ApplicationPolicy
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
        scope.all
      end
    end
end
