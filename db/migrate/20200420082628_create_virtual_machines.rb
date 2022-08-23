# frozen_string_literal: true

class CreateVirtualMachines < ActiveRecord::Migration[6.0]
  def change
    create_table :virtual_machines do |t|
      t.references :exercise, nil: false, foreign_key: true
      t.string :name, nil: false
      t.text :description, nil: false

      t.timestamps
    end

    add_index :virtual_machines, %i[name exercise_id], unique: true
  end
end
