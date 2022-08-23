# frozen_string_literal: true

class AddAddressOffsetToNetworks < ActiveRecord::Migration[6.1]
  def change
    add_column :networks, :address_offset, :integer, default: 0, null: false
  end
end
