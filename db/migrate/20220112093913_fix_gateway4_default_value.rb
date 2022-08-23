# frozen_string_literal: true

class FixGateway4DefaultValue < ActiveRecord::Migration[6.1]
  def change
    change_column :networks, :gateway4, :integer, default: 0
  end
end
