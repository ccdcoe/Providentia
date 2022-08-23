# frozen_string_literal: true

class AddressPoolPolicy < ApplicationPolicy
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
      NetworkPolicy.new(user_context, record.network)
    end

    class Scope < Scope
      def resolve
        scope.all
      end
    end
end
