# frozen_string_literal: true

class Network < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :scoped], scope: :exercise
  has_paper_trail

  belongs_to :exercise
  belongs_to :actor
  has_many :network_interfaces, dependent: :restrict_with_error
  has_many :address_pools, dependent: :destroy
  has_many :virtual_machines, through: :network_interfaces
  has_many :addresses, through: :network_interfaces

  after_create :create_default_pools
  after_save :invalidate_vm_cache
  after_touch :invalidate_vm_cache

  validates :name, :abbreviation, presence: true

  scope :for_grouped_select, -> {
    order(:name).includes(:actor).group_by { |network| network.actor.name }
  }
  scope :search, ->(query) {
    columns = %w{
      networks.name networks.abbreviation
      networks.description networks.domain
      networks.cloud_id
      address_pools.name address_pools.network_address
    }
    left_outer_joins(:address_pools)
      .where(
        columns
          .map { |c| "#{c} ilike :search" }
          .join(' OR '),
        search: "%#{query}%"
      )
      .group(:id)
  }

  def self.to_icon
    'fa-network-wired'
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

    def create_default_pools
      address_pools.create(scope: 'default', ip_family: 'v4', name: 'IPv4')
      address_pools.create(scope: 'default', ip_family: 'v6', name: 'IPv6')
    end
end
