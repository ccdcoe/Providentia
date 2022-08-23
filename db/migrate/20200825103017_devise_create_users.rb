# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :uid,                null: false, default: ''
      t.string :email,              null: false, default: ''
      t.string :name,               null: false, default: ''

      t.timestamps null: false
    end
  end
end
