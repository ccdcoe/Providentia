class RemoveOldNetworkFields < ActiveRecord::Migration[7.0]
  def change
    remove_column :networks, :ipv4
    remove_column :networks, :ipv6
    remove_column :networks, :gateway4
    remove_column :networks, :gateway6
    remove_column :networks, :address_offset
    remove_column :networks, :range_start
    remove_column :networks, :range_end
    remove_column :network_interfaces, :connection
  end
end
