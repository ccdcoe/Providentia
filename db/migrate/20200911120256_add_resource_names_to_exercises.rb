# frozen_string_literal: true

class AddResourceNamesToExercises < ActiveRecord::Migration[6.0]
  def change
    add_column :exercises, :dev_resource_name, :string
    add_column :exercises, :dev_red_resource_name, :string
  end
end
