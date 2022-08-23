# frozen_string_literal: true

class AddCustomDomainToNetworks < ActiveRecord::Migration[6.0]
  def change
    add_column :networks, :ignore_root_domain, :boolean, default: false, null: false
  end
end
