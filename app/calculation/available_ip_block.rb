# frozen_string_literal: true

class AvailableIPBlock < Patterns::Calculation
  private
    def result
      return [] unless subject.ip_v4?

      search_space.map do |address|
        [
          address,
          address
            .to_i
            .step
            .take(options[:count])
            .map { |u32| IPAddress::IPv4.parse_u32(u32, address.prefix) }
        ]
      end.reject do |address, next_addresses|
        addresses_outside_of_search_space?(next_addresses) || addresses_in_used_block?(next_addresses)
      end.map(&:first)
    end

    def search_space
      subject.available_range
    end

    def used_ipv4
      @used_ipv4 ||= (subject.addresses.all_ip_objects - options[:without]).select(&:ipv4?)
    end

    def addresses_in_used_block?(addresses)
      (used_ipv4 & addresses).any?
    end

    def addresses_outside_of_search_space?(addresses)
      (search_space & addresses).size < options[:count]
    end
end
