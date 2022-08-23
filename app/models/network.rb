# frozen_string_literal: true

class Network < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :scoped], scope: :exercise
  has_paper_trail

  belongs_to :exercise
  belongs_to :team
  has_many :network_interfaces, dependent: :restrict_with_error
  has_many :service_checks, dependent: :restrict_with_error
  has_many :address_pools, dependent: :destroy
  has_many :virtual_machines, through: :network_interfaces
  has_many :addresses, through: :network_interfaces
  has_and_belongs_to_many :capabilities,
    after_add: :invalidate_cache, after_remove: :invalidate_cache

  after_create :create_default_pools
  after_save :invalidate_vm_cache
  after_touch :invalidate_vm_cache

  validates :name, :abbreviation, presence: true

  serialize :gateway6, Ipv6Offset # TEMPORARY until migrated

  scope :for_team, ->(team) { where(team: team) }
  scope :for_grouped_select, -> {
    order(:name).includes(:team).group_by { |network| network.team.name }
  }

  def self.to_icon
    'fa-network-wired'
  end

  # TEMPORARY until migrated
  def self.migrate_to_address_pools
    find_each do |network|
      if network.ipv4?
        network.address_pools.where(name: 'Default IPv4').first_or_create(
          ip_family: :v4,
          scope: :default,
          network_address: network.ipv4,
          gateway: network.gateway4,
          range_start: network.range_start,
          range_end: network.range_end
        ).tap do |pool|
          network.addresses.where(mode: %i(ipv4_static ipv4_vip)).each do |address|
            address.update address_pool: pool
          end
        end
      end

      if network.ipv6?
        network.address_pools.where(name: 'Default IPv6').first_or_create(
          ip_family: :v6,
          scope: :default,
          network_address: network.ipv6,
          gateway: network.gateway6.offset
        ).tap do |pool|
          network.addresses.where(mode: %i(ipv6_static ipv6_vip)).each do |address|
            address.update address_pool: pool
          end
        end
      end
    end

    NetworkInterface.where(connection: true).find_each do |nic|
      nic.addresses.joins(:address_pool).mode_ipv4_static.first&.update(connection: true)
    end
  end

  def api_short_name
    "zone_#{slug}".downcase.tr('-', '_')
  end

  def full_domain
    [
      domain,
      ignore_root_domain ? nil : exercise.root_domain
    ].reject(&:blank?).join '.'
  end

  def gateway_hosts
    VirtualMachine
      .distinct
      .where(
        id: network_interfaces
          .joins(:addresses)
          .merge(Address.gateway)
          .pluck(:virtual_machine_id)
      )
  end

  def numbered?
    cloud_id =~ /#|team_nr/ || address_pools.any?(&:numbered?)
  end

  def slug_candidates
    [
      :abbreviation,
      [:abbreviation, :cloud_id]
    ]
  end

  def should_generate_new_friendly_id?
    abbreviation_changed? || super
  end

  private
    def ip_network(index, type)
      return unless public_send(type)
      raw_value = public_send(type).dup
      templated = StringSubstituter.result_for(raw_value, {
        team_nr: index || 1
      })
      IPAddress(templated).network
    end

    def invalidate_vm_cache
      virtual_machines.touch_all
    end

    def invalidate_cache(_capability)
      touch
    end

    def create_default_pools
      address_pools.create(scope: 'default', ip_family: 'v4', name: 'Default IPv4')
      address_pools.create(scope: 'default', ip_family: 'v6', name: 'Default IPv6')
    end
end
