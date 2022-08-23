# frozen_string_literal: true

class AddLocalAdminResourceNameToExercise < ActiveRecord::Migration[7.0]
  def change
    add_column :exercises, :local_admin_resource_name, :string
  end
end
