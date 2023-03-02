# frozen_string_literal: true

class AddConfigMapToNetworks < ActiveRecord::Migration[7.0]
  def change
    add_column :networks, :config_map, :jsonb, default: nil
  end
end
