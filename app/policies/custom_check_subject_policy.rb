# frozen_string_literal: true

class CustomCheckSubjectPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    index?
  end

  def create?
    false
  end

  def new?
    create?
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
end
