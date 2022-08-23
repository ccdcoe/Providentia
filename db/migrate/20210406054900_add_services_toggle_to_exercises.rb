# frozen_string_literal: true

class AddServicesToggleToExercises < ActiveRecord::Migration[6.1]
  def change
    add_column :exercises, :services_read_only, :boolean, null: false, default: true
  end
end
