# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user_context, :record

  delegate :user, :admin?, :local_admin?, :rt?, :user_has_exercise?, to: :user_context

  def initialize(user_context, record)
    @user_context = user_context
    @record = record
  end

  def index?
    admin?
  end

  def show?
    admin? || user_has_exercise?
  end

  def create?
    admin?
  end

  def new?
    admin? || create?
  end

  def update?
    admin?
  end

  def edit?
    admin? || update?
  end

  def destroy?
    admin?
  end

  private
    def exercise
      if record.is_a?(ApplicationRecord)
        record.exercise
      else
        Exercise.new
      end
    end

    class Scope
      attr_reader :user_context, :scope

      delegate :user, :exercise, :admin?, :local_admin?, :rt?, to: :user_context

      def initialize(user_context, scope)
        @user_context = user_context
        @scope = scope
      end

      def resolve
        scope.all
      end

      private
        def accessible_teams_for_user(ex_id = exercise)
          if (user.accessible_exercises[ex_id.to_s] & %w(rt local_admin)).any?
            Team.pluck(:id)
          else
            Team.where.not(name: 'Red').pluck(:id)
          end
        end

        def exercise_ids_for_context
          exercise.present? ? [exercise.id.to_s] : user.accessible_exercises.keys
        end
    end
end
