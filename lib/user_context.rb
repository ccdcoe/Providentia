# frozen_string_literal: true

class UserContext < Struct.new(:user, :exercise)
  def admin?
    user&.admin?
  end

  def local_admin?
    user.accessible_exercises[exercise.id.to_s].include? 'local_admin'
  end

  def rt?
    user.accessible_exercises[exercise.id.to_s].include? 'rt'
  end

  def user_has_exercise?
    return unless exercise
    user.accessible_exercises.include? exercise.id.to_s
  end
end
