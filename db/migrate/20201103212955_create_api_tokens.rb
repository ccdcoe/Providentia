# frozen_string_literal: true

class CreateAPITokens < ActiveRecord::Migration[6.0]
  def change
    create_table :api_tokens do |t|
      t.string :name
      t.string :token
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :api_tokens, :token, unique: true
  end
end
