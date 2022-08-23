# frozen_string_literal: true

class NetworkInterfacePolicy < ApplicationPolicy
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

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
