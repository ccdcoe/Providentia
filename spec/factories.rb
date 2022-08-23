# frozen_string_literal: true

# This will guess the User class
FactoryBot.define do
  factory :capability do
    name { 'MyString' }
    slug { 'MyString' }
    exercise { '' }
  end

  factory :address do
    network_interface { nil }
    mode { 1 }
    offset { 'MyString' }
    dns_enabled { false }
  end

  factory :service_check do
    service { nil }
    network { nil }
    protocol { 1 }
    destination_port { 1 }
  end

  factory :exercise do
    name { 'Crocked Fields' }
    abbreviation { 'CF' }
    dev_resource_name { "#{abbreviation.upcase}_GT" }
    dev_red_resource_name { "#{abbreviation.upcase}_RT" }
  end

  factory :virtual_machine do
    name { 'CoolTarget' }
    team
    operating_system
    exercise
  end

  factory :operating_system do
    name { 'DoorOs' }
    cloud_id { 'door_os' }
  end

  factory :team do
    name { 'blurple' }
  end

  factory :network do
    name { 'moo' }
    abbreviation { 'M' }
    team
    exercise
  end

  factory :network_interface do
    network
    virtual_machine
  end
end
