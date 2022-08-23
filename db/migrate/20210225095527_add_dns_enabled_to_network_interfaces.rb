# frozen_string_literal: true

class AddDnsEnabledToNetworkInterfaces < ActiveRecord::Migration[6.1]
  def change
    add_column :network_interfaces, :dns_enabled, :boolean, default: false, null: false
  end
end
