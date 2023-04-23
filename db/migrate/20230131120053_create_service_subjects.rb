# frozen_string_literal: true

class CreateServiceSubjects < ActiveRecord::Migration[7.0]
  def change
    create_table :service_subjects do |t|
      t.references :service, null: false, foreign_key: true
      t.jsonb :customization_spec_ids, null: true, default: []
      t.jsonb :match_conditions, null: false, default: {}

      t.timestamps
    end
  end
end
