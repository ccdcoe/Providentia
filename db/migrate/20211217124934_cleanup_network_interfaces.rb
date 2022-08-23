# frozen_string_literal: true

class CleanupNetworkInterfaces < ActiveRecord::Migration[6.1]
  def change
    remove_column :network_interfaces, :ip_offset
    remove_column :network_interfaces, :ip_offset6
    remove_column :network_interfaces, :vlan
    remove_column :network_interfaces, :reservation_only
    remove_column :network_interfaces, :dns_enabled
  end
end
