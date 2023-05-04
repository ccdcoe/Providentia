# frozen_string_literal: true

class Check
  class Protocols
    PROTOCOLS = {
      l3: {
        icmp: 1
      },
      l4: {
        tcp: 2,
        udp: 3,
        tcp_and_udp: 4,
        sctp: 5
      },
      l7: {
        http: 10,
        https: 11,
        smtp: 12,
        rdp: 13,
        ssh: 14,
        ftp: 15,
        vnc: 16,
        dns: 17,
        ntp: 18
      }
    }.freeze

    def self.to_enum_hash
      PROTOCOLS.values.reduce(&:merge)
    end

    def self.to_grouped_options
      PROTOCOLS.map do |layer, protocols|
        [
          "Layer #{layer.to_s[-1]}", protocols.keys.map do |protocol|
            [I18n.t("protocols.#{protocol}"), protocol]
          end
        ]
      end
    end
  end
end
