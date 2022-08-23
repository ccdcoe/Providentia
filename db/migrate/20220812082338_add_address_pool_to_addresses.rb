# frozen_string_literal: true

class AddAddressPoolToAddresses < ActiveRecord::Migration[7.0]
  def change
    add_reference :addresses, :address_pool, foreign_key: true
  end
end
