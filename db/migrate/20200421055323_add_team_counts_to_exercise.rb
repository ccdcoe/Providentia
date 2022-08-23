# frozen_string_literal: true

class AddTeamCountsToExercise < ActiveRecord::Migration[6.0]
  def change
    add_column :exercises, :blue_team_count, :integer
    add_column :exercises, :dev_team_count, :integer
  end
end
