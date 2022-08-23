# frozen_string_literal: true

class CreateOperatingSystems < ActiveRecord::Migration[6.0]
  def change
    create_table :operating_systems do |t|
      t.string :name
      t.string :cloud_id

      t.timestamps
    end

    add_index :operating_systems, :cloud_id, unique: true
  end
end
