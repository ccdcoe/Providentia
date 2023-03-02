# frozen_string_literal: true

class CloneExerciseForm < Patterns::Form
  param_key 'clone'

  attribute :exercise_id, Integer
  attribute :name, String
  attribute :abbreviation, String

  validate :exercise_valid?

  def source_name
    source_exercise.name
  end

  def source_abbreviation
    source_exercise.abbreviation
  end

  private
    def persist
      calculation.cached_result
    end

    def exercise_valid?
      calculation.cloned_environment.valid?
      errors.copy!(calculation.cloned_environment.errors)
    end

    def calculation
      @calculation ||= CloneEnvironment.new(exercise_id, attributes)
    end

    def source_exercise
      @source_exercise ||= Exercise.find(exercise_id)
    end
end
