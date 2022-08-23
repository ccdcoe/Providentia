# frozen_string_literal: true

class AddIPOffset6ToNetworkInterfaces < ActiveRecord::Migration[6.0]
  def change
    add_column :network_interfaces, :ip_offset6, :bigint
  end
end
