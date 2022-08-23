# frozen_string_literal: true

class RemoveOldGeneratedField < ActiveRecord::Migration[6.1]
  def change
    remove_column :virtual_machines, :generated_deployable_instances
  end
end
