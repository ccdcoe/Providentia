# frozen_string_literal: true

class Address < ApplicationRecord
  has_paper_trail

  belongs_to :network_interface, touch: true
  belongs_to :address_pool, touch: true, optional: true
  has_one :virtual_machine, through: :network_interface
  has_one :network, through: :network_interface

  delegate :exercise, to: :network

  enum mode: {
    ipv4_static: 1,
    ipv4_dhcp: 2,
    ipv6_static: 3,
    ipv6_slaac: 4,
    ipv6_dhcp: 5,
    ipv6_linklocal: 6,
    ipv6_uniqlocal: 7,
    ipv4_vip: 8,
    ipv6_vip: 9
  }, _prefix: :mode, _default: 'ipv4_static'

  scope :for_used_addresses, ->() {
    includes({ virtual_machine: [:exercise] }, :network).
      where.not(offset: nil)
  }

  scope :all_ip_objects, -> {
    includes(:virtual_machine, :network)
      .flat_map(&:all_ip_objects)
      .compact
  }

  scope :for_api, -> {
    where(mode: %i(ipv4_dhcp ipv6_dhcp ipv6_slaac))
      .or(where.not(offset: nil))
  }

  scope :for_search, -> {
    where(mode: %i(ipv4_static ipv4_vip ipv6_static ipv6_linklocal ipv6_uniqlocal ipv6_vip))
    includes(:network)
    .where.not(offset: nil)
    .order(%i(mode offset))
    .limit(4)
  }

  scope :gateway, -> {
    joins(:address_pool)
      .where(mode: %w(ipv4_static ipv4_vip ipv6_static ipv6_vip))
      .where('addresses.offset = address_pools.gateway::varchar')
  }

  before_validation :parse_ipv6, :parse_ipv4
  before_save :clear_on_mode_change, :populate_first_pool_if_empty, :clear_offset
  after_save :clear_connection_flag_on_other_addresses

  validate :check_ip_offset6, :check_ip_offset4, :check_overlap

  def self.to_icon
    'fa-id-badge'
  end

  def ip_family
    if ipv4?
      :ipv4
    elsif ipv6?
      :ipv6
    end
  end

  def ip_family_network(team = nil)
    case mode
    when 'ipv4_static', 'ipv4_vip', 'ipv6_static', 'ipv6_vip'
      address_pool.ip_network(team)
    when 'ipv6_linklocal'
      IPAddress::IPv6.new('fe80::/10')
    when 'ipv6_uniqlocal'
      IPAddress::IPv6.new('fc00::/7')
    end
  end

  def ip_family_network_template
    case mode
    when 'ipv4_static', 'ipv4_vip', 'ipv6_static', 'ipv6_vip'
      address_pool.network_address
    when 'ipv6_linklocal'
      'fe80::/10'
    when 'ipv6_uniqlocal'
      'fc00::/7'
    end
  end

  def ip_object(sequential = nil, team = nil)
    return unless fixed? && ip_family_network_template.present?
    static_offset = -1
    static_offset -= 1 if ipv6?

    if address_pool&.numbered?
      ip_family_network(team).allocate(offset.to_i + (sequential || 1) + static_offset)
    else
      ip_family_network.allocate(offset.to_i + (sequential || 1) + (team || 1) + static_offset - 1)
    end
  end

  def ipv4?
    mode_ipv4_static? || mode_ipv4_dhcp? || mode_ipv4_vip?
  end

  def ipv6?
    mode_ipv6_static? || mode_ipv6_slaac? || mode_ipv6_dhcp? || mode_ipv6_linklocal? || mode_ipv6_uniqlocal? || mode_ipv6_vip?
  end

  def vip?
    mode_ipv4_vip? || mode_ipv6_vip?
  end

  def fixed?
    mode_ipv4_static? || mode_ipv6_static? || mode_ipv6_linklocal? || mode_ipv6_uniqlocal? || vip?
  end

  def needs_pool?
    mode_ipv4_static? || mode_ipv6_static? || vip?
  end

  def parsed_ipv6
    Ipv6Offset.load(offset)
  end

  def parsed_ipv6=(input)
    return unless input.present?
    @parsed_ipv6 = input
  end

  def offset_address
    return unless offset
    ip_object.to_s
  end

  def offset_address=(input)
    return unless input.present?
    @offset_address = input
  end

  def all_ip_objects
    return unless offset
    if virtual_machine.custom_instance_count
      1.upto(virtual_machine.custom_instance_count).map do |seq|
        ip_object(seq)
      end
    elsif !address_pool.numbered? && virtual_machine.deploy_count > 1
      1.upto(virtual_machine.deploy_count).map do |team_nr|
        ip_object(nil, team_nr)
      end
    else
      [ip_object]
    end
  end

  private
    def check_overlap
      return unless offset && !vip?
      other_used_addresses = address_pool.addresses
        .where.not(id: id)
        .where(mode: self.mode)
        .all_ip_objects

      errors.add(:offset, :overlap) if (other_used_addresses & all_ip_objects).any?
    end

    def parse_ipv6
      return unless @parsed_ipv6
      self.offset = Ipv6Offset.dump(@parsed_ipv6)
    rescue ArgumentError
      self.errors.add(:parsed_ipv6, :invalid)
    rescue StopIteration
      self.errors.add(:parsed_ipv6, :invalid)
    end

    def parse_ipv4
      return unless @offset_address
      network_object = ip_family_network

      address = IPAddress::IPv4.new("#{@offset_address}/#{network_object.prefix}") rescue nil
      if address && network_object.include?(address)
        self.offset = address.u32 - network_object.network_u32 - 1
      else
        errors.add(:offset, :invalid)
        errors.add(:offset_address, :invalid)
      end
    end

    def check_ip_offset4
      return unless mode_ipv4_static? && offset

      address = ip_family_network.allocate(offset.to_i)
      errors.add(:offset, :invalid) unless address_pool.available_range.include?(address)
    rescue StopIteration
      self.offset = self.offset_was
      errors.add(:offset, :invalid)
    end

    def check_ip_offset6
      return unless fixed? && ipv6? && offset
      ip_family_network.allocate(offset.to_i - 1)
    rescue StopIteration
      self.offset = self.offset_was
      errors.add(:parsed_ipv6, :invalid)
    end

    def clear_on_mode_change
      return unless mode_changed?
      self.address_pool = nil
      self.connection = false
      self.dns_enabled = false if fixed?
      true
    end

    def populate_first_pool_if_empty
      return unless mode_ipv4_static? || mode_ipv4_vip? || mode_ipv6_static? || mode_ipv6_vip?
      return if address_pool

      if ipv4?
        self.address_pool = network.address_pools.ip_v4.first
      else
        self.address_pool = network.address_pools.ip_v6.first
      end
    end

    def clear_offset
      return true if !mode_changed? || new_record?
      self.offset = nil
      true
    end

    def clear_connection_flag_on_other_addresses
      return if id_previously_changed?
      return unless connection == true || !connection_changed?
      virtual_machine.addresses.where.not(id: self.id).update_all(connection: false)
    end
end
