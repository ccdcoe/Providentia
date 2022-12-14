# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_08_18_121547) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "address_pools", force: :cascade do |t|
    t.bigint "network_id", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.integer "ip_family", default: 1, null: false
    t.integer "scope", default: 1, null: false
    t.string "network_address"
    t.bigint "gateway", default: 0
    t.integer "range_start"
    t.integer "range_end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["network_id"], name: "index_address_pools_on_network_id"
  end

  create_table "addresses", force: :cascade do |t|
    t.bigint "network_interface_id", null: false
    t.integer "mode", null: false
    t.string "offset"
    t.boolean "dns_enabled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "address_pool_id"
    t.boolean "connection", default: false, null: false
    t.index ["address_pool_id"], name: "index_addresses_on_address_pool_id"
    t.index ["network_interface_id"], name: "index_addresses_on_network_interface_id"
  end

  create_table "api_tokens", force: :cascade do |t|
    t.string "name"
    t.string "token"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_api_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_api_tokens_on_user_id"
  end

  create_table "capabilities", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.text "description"
    t.bigint "exercise_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id"], name: "index_capabilities_on_exercise_id"
  end

  create_table "capabilities_networks", id: false, force: :cascade do |t|
    t.bigint "capability_id", null: false
    t.bigint "network_id", null: false
    t.index ["network_id", "capability_id"], name: "network_capability_index"
  end

  create_table "capabilities_virtual_machines", id: false, force: :cascade do |t|
    t.bigint "capability_id", null: false
    t.bigint "virtual_machine_id", null: false
    t.index ["virtual_machine_id", "capability_id"], name: "vm_capability_index"
  end

  create_table "exercises", force: :cascade do |t|
    t.string "name", null: false
    t.string "abbreviation", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "blue_team_count"
    t.integer "dev_team_count"
    t.string "root_domain"
    t.string "dev_resource_name"
    t.string "dev_red_resource_name"
    t.string "slug"
    t.boolean "services_read_only", default: true, null: false
    t.boolean "archived", default: false, null: false
    t.integer "mode", default: 1, null: false
    t.string "description"
    t.string "local_admin_resource_name"
    t.index ["abbreviation"], name: "index_exercises_on_abbreviation", unique: true
    t.index ["slug"], name: "index_exercises_on_slug", unique: true
  end

  create_table "network_interfaces", force: :cascade do |t|
    t.bigint "virtual_machine_id", null: false
    t.bigint "network_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "egress", default: false, null: false
    t.boolean "connection", default: false, null: false
    t.index ["network_id"], name: "index_network_interfaces_on_network_id"
    t.index ["virtual_machine_id"], name: "index_network_interfaces_on_virtual_machine_id"
  end

  create_table "networks", force: :cascade do |t|
    t.bigint "exercise_id", null: false
    t.string "name", null: false
    t.string "abbreviation", null: false
    t.string "cloud_id"
    t.string "ipv4"
    t.string "ipv6"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "team_id", null: false
    t.string "domain"
    t.integer "gateway4", default: 0
    t.bigint "gateway6", default: 1
    t.boolean "ignore_root_domain", default: false, null: false
    t.string "slug"
    t.integer "address_offset", default: 0, null: false
    t.integer "range_start"
    t.integer "range_end"
    t.index ["exercise_id"], name: "index_networks_on_exercise_id"
    t.index ["team_id"], name: "index_networks_on_team_id"
  end

  create_table "operating_systems", force: :cascade do |t|
    t.string "name"
    t.string "cloud_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ancestry"
    t.string "slug"
    t.integer "cpu"
    t.integer "ram"
    t.integer "primary_disk_size"
    t.index ["ancestry"], name: "index_operating_systems_on_ancestry"
    t.index ["cloud_id"], name: "index_operating_systems_on_cloud_id", unique: true
    t.index ["slug"], name: "index_operating_systems_on_slug", unique: true
  end

  create_table "service_checks", force: :cascade do |t|
    t.bigint "service_id", null: false
    t.bigint "network_id", null: false
    t.integer "protocol", default: 0, null: false
    t.integer "ip_family", default: 0, null: false
    t.integer "destination_port"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["network_id"], name: "index_service_checks_on_network_id"
    t.index ["service_id"], name: "index_service_checks_on_service_id"
  end

  create_table "services", force: :cascade do |t|
    t.bigint "exercise_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.index ["exercise_id"], name: "index_services_on_exercise_id"
  end

  create_table "services_virtual_machines", id: false, force: :cascade do |t|
    t.bigint "service_id", null: false
    t.bigint "virtual_machine_id", null: false
    t.index ["virtual_machine_id", "service_id"], name: "vm_service_index"
  end

  create_table "special_checks", force: :cascade do |t|
    t.bigint "service_id", null: false
    t.bigint "network_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["network_id"], name: "index_special_checks_on_network_id"
    t.index ["service_id"], name: "index_special_checks_on_service_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "uid", default: "", null: false
    t.string "email", default: "", null: false
    t.string "name", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.jsonb "permissions", default: {}
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.jsonb "object"
    t.datetime "created_at", precision: nil
    t.jsonb "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "virtual_machines", force: :cascade do |t|
    t.bigint "exercise_id"
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "team_id", null: false
    t.integer "deploy_mode", default: 0, null: false
    t.integer "custom_instance_count"
    t.bigint "operating_system_id"
    t.string "role"
    t.integer "cpu"
    t.integer "ram"
    t.string "hostname"
    t.integer "system_owner_id"
    t.boolean "bt_visible", default: true, null: false
    t.integer "primary_disk_size"
    t.index ["exercise_id"], name: "index_virtual_machines_on_exercise_id"
    t.index ["name", "exercise_id"], name: "index_virtual_machines_on_name_and_exercise_id", unique: true
    t.index ["operating_system_id"], name: "index_virtual_machines_on_operating_system_id"
    t.index ["team_id"], name: "index_virtual_machines_on_team_id"
  end

  add_foreign_key "address_pools", "networks"
  add_foreign_key "addresses", "address_pools"
  add_foreign_key "addresses", "network_interfaces"
  add_foreign_key "api_tokens", "users"
  add_foreign_key "capabilities", "exercises"
  add_foreign_key "network_interfaces", "networks"
  add_foreign_key "network_interfaces", "virtual_machines"
  add_foreign_key "networks", "exercises"
  add_foreign_key "networks", "teams"
  add_foreign_key "service_checks", "networks"
  add_foreign_key "service_checks", "services"
  add_foreign_key "services", "exercises"
  add_foreign_key "special_checks", "networks"
  add_foreign_key "special_checks", "services"
  add_foreign_key "virtual_machines", "exercises"
  add_foreign_key "virtual_machines", "operating_systems"
  add_foreign_key "virtual_machines", "teams"
  add_foreign_key "virtual_machines", "users", column: "system_owner_id"
end
