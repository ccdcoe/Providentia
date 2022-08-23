# frozen_string_literal: true

class AddDomainToNetworks < ActiveRecord::Migration[6.0]
  def change
    add_column :networks, :domain, :string
  end
end
