# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

OperatingSystem.where(name: 'Linux', cloud_id: 'linux').first_or_create!
OperatingSystem.where(name: 'macOS', cloud_id: 'macos').first_or_create!
OperatingSystem.where(name: 'Windows', cloud_id: 'windows').first_or_create!
OperatingSystem.where(name: 'Network devices', cloud_id: 'networkdevices').first_or_create!

if Rails.env.development?
  Exercise.where(name: 'Test Exercise', abbreviation: 'TE').first_or_create!
  Exercise.update_all(
    dev_red_resource_name: 'TE_RT',
    dev_resource_name: 'TE_GT',
    local_admin_resource_name: 'TE_Admin'
  )
end
