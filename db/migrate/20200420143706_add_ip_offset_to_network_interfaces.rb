# frozen_string_literal: true

class AddIPOffsetToNetworkInterfaces < ActiveRecord::Migration[6.0]
  def change
    add_column :network_interfaces, :ip_offset, :integer
  end
end
