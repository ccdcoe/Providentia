# frozen_string_literal: true

class RemoveTrunkFromNetworks < ActiveRecord::Migration[6.1]
  def change
    remove_column :networks, :trunk
  end
end
