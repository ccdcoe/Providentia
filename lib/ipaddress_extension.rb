# frozen_string_literal: true

module IpaddressExtension
  module IPv4
    def eql?(oth)
      self.hash == oth.hash
    end

    def hash
      [ to_u32, prefix.to_u32 ].hash
    end
  end

  module IPv6
    def eql?(oth)
      self.hash == oth.hash
    end

    def hash
      [ to_u128, prefix.to_u128 ].hash
    end
  end
end

IPAddress::IPv4.include IpaddressExtension::IPv4
IPAddress::IPv6.include IpaddressExtension::IPv6
