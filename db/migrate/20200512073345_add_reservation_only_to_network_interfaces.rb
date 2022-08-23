# frozen_string_literal: true

class AddReservationOnlyToNetworkInterfaces < ActiveRecord::Migration[6.0]
  def change
    add_column :network_interfaces, :reservation_only, :boolean, null: false, default: false
  end
end
