# frozen_string_literal: true

class CreateActorNumberConfigs < ActiveRecord::Migration[7.0]
  def change
    create_table :actor_number_configs do |t|
      t.references :actor, null: false, foreign_key: true
      t.string :name, null: false
      t.jsonb :config_map, null: false, default: {}
      t.jsonb :matcher, null: false, default: []

      t.timestamps
    end
  end
end
