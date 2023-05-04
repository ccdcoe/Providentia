# frozen_string_literal: true

class CreateCustomCheckSubjects < ActiveRecord::Migration[7.0]
  def change
    create_table :custom_check_subjects do |t|
      t.string :base_class, null: false
      t.string :meaning, null: false

      t.timestamps
    end
  end
end
