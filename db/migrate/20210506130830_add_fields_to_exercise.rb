# frozen_string_literal: true

class AddFieldsToExercise < ActiveRecord::Migration[6.1]
  def change
    add_column :exercises, :mode, :integer, default: 1, null: false
    add_column :exercises, :description, :string
  end
end
