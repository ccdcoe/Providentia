# frozen_string_literal: true

class AddUserPermissionsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :permissions, :jsonb, default: {}
  end
end
