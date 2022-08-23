# frozen_string_literal: true

class AddressPolicy < ApplicationPolicy
  def show?
    VirtualMachinePolicy.new(
      user_context,
      record.virtual_machine
    ).show?
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
    class Scope < Scope
      def resolve
        scope.all
      end
    end
end
