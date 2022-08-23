# frozen_string_literal: true

class ChangeIpv6OffsetToString < ActiveRecord::Migration[6.0]
  def change
    change_column :network_interfaces, :ip_offset6, :string
  end
end
