# frozen_string_literal: true

class AddVlanToNetworkInterfaces < ActiveRecord::Migration[6.0]
  def change
    add_column :network_interfaces, :vlan, :string
  end
end
