# frozen_string_literal: true

class ChangeExercises < ActiveRecord::Migration[6.0]
  def change
    change_column :exercises, :name, :string, null: false
    change_column :exercises, :abbreviation, :string, null: false
  end
end
