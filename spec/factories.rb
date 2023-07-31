# frozen_string_literal: true

# This will guess the User class
FactoryBot.define do
  factory :actor_number_config do
    actor
    config_map { {} }
    name { 'MyString' }
    matcher { [] }
  end

  factory :customization_spec do
    virtual_machine
    name { 'MyString' }
    role_name { 'MyString' }
    dns_name { 'MyString' }
    description { 'MyText' }
  end

  factory :capability do
    name { 'MyString' }
    slug { 'MyString' }
    exercise { '' }
  end

  factory :address do
    network_interface
    mode { 1 }
    offset { 'MyString' }
    dns_enabled { false }
  end

  factory :address_pool do
    network
    network_address { '1.2.3.0/24' }
  end

  factory :exercise do
    name { 'Crocked Fields' }
    abbreviation { Faker::Alphanumeric.alpha(number: 5) }
    dev_resource_name { "#{abbreviation.upcase}_GT" }
    dev_red_resource_name { "#{abbreviation.upcase}_RT" }
    actors { build_list(:actor, 2, exercise: instance) }
  end

  factory :virtual_machine do
    name { 'CoolTarget' }
    actor
    operating_system
    exercise
  end

  factory :operating_system do
    name { 'DoorOs' }
    cloud_id { 'door_os' }
  end

  factory :actor do
    name { Faker::Company.department }
    abbreviation { name.dasherize }
    exercise

    trait :numbered do
      number { 3 }
    end

    trait :numbered_2 do
      number { 2 }
    end
  end

  factory :network do
    name { Faker::Internet.domain_name }
    abbreviation { Faker::Alphanumeric.alpha(number: 5) }
    actor { exercise.actors.sample }
    exercise
  end

  factory :network_interface do
    network
    virtual_machine
  end

  factory :user do
  end

  factory :api_token do
    user
  end
end
