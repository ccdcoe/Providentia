# frozen_string_literal: true

class AddressPool < ApplicationRecord
  extend FriendlyId
  has_paper_trail
  friendly_id :slug_candidates, use: [:slugged, :scoped], scope: :network

  belongs_to :network, touch: true
  has_one :exercise, through: :network
  has_many :addresses

  enum ip_family: {
    v4: 1,
    v6: 2,
  }, _prefix: :ip, _default: 'v4'

  enum scope: {
    default: 1,
    mgmt: 2,
    other: 999,
  }, _prefix: :scope, _default: 'default'

  validates :name, :ip_family, :scope, presence: true
  validates :network_address, format: {
    with: /\A(?>(?>{{\s*[-,\w.'|:\s]+\s*}}|[0-9#]){1,3}\.){3}[0-9]{1,3}(\/([0-9]|[1-2][0-9]|3[0-2]))\z/,
    allow_nil: true
  }, if: :ip_v4?
  validates :network_address, format: {
    with: /\A((((?>{{\s*[-,\w.'|:\s]+\s*}}|[0-9A-Fa-f#]){1,4}:){7}((?>{{\s*[-,\w.'|:\s]+\s*}}|[0-9A-Fa-f#]){1,4}|:))|(((?>{{\s*[-,\w.'|:\s]+\s*}}|[0-9A-Fa-f#]){1,4}:){6}(:(?>{{\s*[-,\w.'|:\s]+\s*}}|[0-9A-Fa-f#]){1,4}|((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3})|:))|(((?>{{\s*[-,\w.'|:\s]+\s*}}|[0-9A-Fa-f#]){1,4}:){5}(((:(?>{{\s*[-,\w.'|:\s]+\s*}}|[0-9A-Fa-f#]){1,4}){1,2})|:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3})|:))|(((?>{{\s*[-,\w.'|:\s]+\s*}}|[0-9A-Fa-f#]){1,4}:){4}(((:(?>{{\s*[-,\w.'|:\s]+\s*}}|[0-9A-Fa-f#]){1,4}){1,3})|((:(?>{{\s*[-,\w.'|:\s]+\s*}}|[0-9A-Fa-f#]){1,4})?:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(((?>{{\s*[-,\w.'|:\s]+\s*}}|[0-9A-Fa-f#]){1,4}:){3}(((:(?>{{\s*[-,\w.'|:\s]+\s*}}|[0-9A-Fa-f#]){1,4}){1,4})|((:(?>{{\s*[-,\w.'|:\s]+\s*}}|[0-9A-Fa-f#]){1,4}){0,2}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(((?>{{\s*[-,\w.'|:\s]+\s*}}|[0-9A-Fa-f#]){1,4}:){2}(((:(?>{{\s*[-,\w.'|:\s]+\s*}}|[0-9A-Fa-f#]){1,4}){1,5})|((:(?>{{\s*[-,\w.'|:\s]+\s*}}|[0-9A-Fa-f#]){1,4}){0,3}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(((?>{{\s*[-,\w.'|:\s]+\s*}}|[0-9A-Fa-f#]){1,4}:){1}(((:(?>{{\s*[-,\w.'|:\s]+\s*}}|[0-9A-Fa-f#]){1,4}){1,6})|((:(?>{{\s*[-,\w.'|:\s]+\s*}}|[0-9A-Fa-f#]){1,4}){0,4}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(:(((:(?>{{\s*[-,\w.'|:\s]+\s*}}|[0-9A-Fa-f#]){1,4}){1,7})|((:(?>{{\s*[-,\w.'|:\s]+\s*}}|[0-9A-Fa-f#]){1,4}){0,5}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:)))(%.+)?s*(\/([0-9]|[1-9][0-9]|1[0-1][0-9]|12[0-8]))?\z/,
    allow_nil: true
  }, if: :ip_v6?

  scope :for_address, ->(address) {
    where(ip_family: address.ipv4? ? :v4 : :v6)
  }

  before_update :clear_dangling_addresses
  after_validation :revert_invalid_network_values

  def self.to_icon
    'fa-network-wired'
  end

  def numbered?
    network_address =~ /#|team_nr/
  end

  def gateway_address_object
    Address.new(
      mode: address_mode,
      address_pool: self,
      network: network,
      offset: gateway
    )
  end

  def gateway_ip(team = nil)
    return unless gateway
    ip_network(team).allocate(gateway - (ip_v6? ? 1 : 0))
  end

  def ip_network(team = nil)
    return unless network_address
    templated = StringSubstituter.result_for(network_address.dup, { team_nr: team || 1 })
    IPAddress(templated).network
  end

  def available_range
    raise 'attempt to iterate over ipv6, bad idea!' unless ip_v4?
    @available_ipv4_range ||= ip_network.hosts[(range_start || 0)..(range_end || -1)]
  end

  def should_generate_new_friendly_id?
    name_changed? || scope_changed? || ip_family_changed? || super
  end

  def slug_candidates
    [
      [:scope, :name],
      [:scope, :ip_family, :name]
    ]
  end

  private
    def address_mode
      "ip#{ip_family}_static"
    end

    def clear_dangling_addresses
      return unless network_address_changed? || range_start_changed? || range_end_changed?
      clear_dangling_ipv4 if ip_v4?
      clear_dangling_ipv6 if ip_v6?
    end

    def clear_dangling_ipv4
      if network_address
        all_hosts = available_range.map(&:to_u32).to_set
        addresses.mode_ipv4_static.where.not(offset: nil).each do |address|
          used_addresses = address.all_ip_objects.map(&:to_u32).to_set
          next if all_hosts > used_addresses # no "overflowing" addresses
          address.update(offset: nil)
        end
      else
        addresses.where(mode: %i(ipv4_static ipv4_vip))
      end
    end

    def clear_dangling_ipv6
      addresses.where(mode: %i(ipv6_static ipv6_vip)).where.not(offset: nil).each do |address|
        next if address.all_ip_objects.all? { |ip|
          ip_network.include? IPAddress::IPv6.new("#{ip}/#{ip_network.prefix}")
        }
        address.update(offset: nil)
      end
    end

    def revert_invalid_network_values
      self.gateway = gateway_was if errors[:gateway].any?
      self.network_address = network_address_was if errors[:network_address].any?
    end
end
