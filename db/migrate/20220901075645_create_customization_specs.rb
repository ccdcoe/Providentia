# frozen_string_literal: true

class CreateCustomizationSpecs < ActiveRecord::Migration[7.0]
  def change
    create_table :customization_specs do |t|
      t.references :virtual_machine, null: false, foreign_key: true
      t.integer :mode, null: false, default: 1
      t.string :name
      t.string :slug
      t.string :role_name
      t.string :dns_name
      t.text :description

      t.timestamps
      t.index [:name, :virtual_machine_id], unique: true
    end

    create_join_table :services, :customization_specs do |t|
      t.index [:customization_spec_id, :service_id], name: 'spec_service_index'
    end

    create_join_table :capabilities, :customization_specs do |t|
      t.index [:customization_spec_id, :capability_id], name: 'spec_capability_index'
    end
  end
end
