# frozen_string_literal: true

class TeamPolicy < ApplicationPolicy
  def create?
    false
  end

  class Scope < Scope
    def resolve
      if admin? || local_admin? || rt?
        scope.all
      else
        scope.where.not(name: 'Red')
      end
    end
  end
end
