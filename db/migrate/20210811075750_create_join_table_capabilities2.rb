# frozen_string_literal: true

class CreateJoinTableCapabilities2 < ActiveRecord::Migration[6.1]
  def change
    create_join_table :capabilities, :networks do |t|
      t.index [:network_id, :capability_id], name: 'network_capability_index'
    end
  end
end
