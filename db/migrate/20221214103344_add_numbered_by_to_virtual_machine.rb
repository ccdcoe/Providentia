# frozen_string_literal: true

class AddNumberedByToVirtualMachine < ActiveRecord::Migration[7.0]
  def change
    add_column :virtual_machines, :numbered_by, :integer, null: true, foreign_key: true, to_table: :actors
  end
end
