# frozen_string_literal: true

class AddressPoolForm < Patterns::Form
  param_key 'address_pool'

  attribute :name, String
  attribute :ip_family, Integer
  attribute :scope, Integer
  attribute :network_address, String
  attribute :gateway, String
  attribute :range_start, String
  attribute :range_end, String

  ADDRESS_FIELDS = %i(gateway_address range_start_address range_end_address).freeze
  ADDRESS_FIELDS.each do |field|
    define_method field do
      value = resource.public_send(field.to_s.sub('_address', ''))
      return unless value && resource.ip_network
      UnsubstitutedAddress.result_for(
        resource.ip_network.allocate(value),
        address_pool: resource
      ).to_s
    end

    define_method "#{field}=" do |input|
      return super(input) unless resource.ip_v4?

      if input == ''
        public_send("#{field.to_s.sub('_address', '')}=", nil)
      else
        address = IPAddress::IPv4.new("#{StringSubstituter.result_for(input, { team_nr: 1 })}/#{resource.ip_network.prefix}") rescue nil
        if address && resource.ip_network.include?(address)
          public_send("#{field.to_s.sub('_address', '')}=", address.u32 - resource.ip_network.network_u32 - 1)
        else
          errors.add(field.to_s.sub('_address', '').to_sym, :invalid)
          errors.add(field, :invalid)
        end
      end
    end
  end

  def gateway6
    return if !resource.ip_v6? || attributes[:gateway].nil?
    Ipv6Offset.load(attributes[:gateway]).to_s.presence || "0"
  end

  def gateway6=(input)
    self.gateway = if input.blank?
      nil
    else
      Ipv6Offset.dump(input)
    end
  rescue
    self.gateway = resource.gateway
  end

  private
    def persist
      sort_range_fields
      resource.update(attributes)
    end

    def sort_range_fields
      return unless range_start.present? && range_end.present?
      self.range_start, self.range_end = [range_start.to_i, range_end.to_i].sort
    end
end
