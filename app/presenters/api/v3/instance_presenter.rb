# frozen_string_literal: true

module API
  module V3
    class InstancePresenter < Struct.new(:spec, :sequential_number, :team_number)
      delegate :operating_system, to: :vm

      def as_json
        {
          id: inventory_name,
          parent_id:,
          vm_name:,
          team_unique_id: name,
          hostname:,
          domain: substitute(connection_namespec.domain.to_s),
          fqdn: substitute(connection_namespec.fqdn.to_s),
          connection_address: connection_address&.ip_object(sequential_number, team_number)&.to_s,
          interfaces:,
          checks:,
          tags:,
          config_map: {}
        }.merge(team_numbers).merge(sequence_info)
      end

      private
        def vm
          spec.virtual_machine
        end

        def parent_id
          return if spec.mode_host?

          substitute(
            [
              host_spec.slug,
              hostname_sequence_suffix,
              hostname_team_suffix
            ].compact.join('_')
          )
        end

        def connection_namespec
          @connection_namespec ||= HostnameGenerator.result_for(spec, nic: connection_nic)
        end

        def substitute(text)
          StringSubstituter.result_for(
            text,
            {
              team_nr: team_number,
              seq: sequential_number
            }
          )
        end

        def team_numbers
          return {} unless team_number
          {
            team_nr: team_number,
            team_nr_str: team_number.to_s.rjust(2, '0'),
          }
        end

        def sequence_info
          return {} unless vm.custom_instance_count.to_i > 1

          { sequence_index: sequential_number }
        end

        def hostname_sequence_suffix
          '{{ seq }}' if vm.custom_instance_count.to_i > 1
        end

        def hostname_team_suffix
          't{{ team_nr_str }}' if vm.numbered_actor
        end

        def inventory_name
          substitute(
            [
              spec.slug,
              hostname_sequence_suffix,
              hostname_team_suffix
            ].compact.join('_')
          )
        end

        def name
          substitute(
            [
              spec.slug,
              hostname_sequence_suffix
            ].compact.join('_')
          )
        end

        def vm_name
          spec = HostnameGenerator.result_for(host_spec, nic: connection_nic)
          substitute("#{vm.exercise.abbreviation}_#{spec.fqdn}").downcase
        end

        def host_spec
          vm.host_spec.tap { |spec| spec.virtual_machine = vm } # set manually to avoid extra db call
        end

        def hostname
          substitute(
            HostnameGenerator.result_for(
              spec,
              nic: network_interfaces.find { |nic| !nic.network.numbered? } ||
                network_interfaces.first ||
                vm.dup.network_interfaces.build
            ).hostname
          )
        end

        def network_interfaces
          Current.interfaces_cache ||= {}
          Current.interfaces_cache[vm.id]
        end

        def connection_nic
          network_interfaces.detect(&:connection?)
        end

        def interfaces
          network_interfaces.map do |nic|
            namespec = HostnameGenerator.result_for(spec, nic:)
            {
              network_id: nic.network.slug,
              cloud_id: substitute(nic.network.cloud_id.to_s),
              domain: substitute(nic.network.full_domain),
              fqdn: substitute(namespec.fqdn),
              egress: nic.egress?,
              connection: nic.addresses.any?(&:connection),
              addresses: nic
                .addresses.order(:created_at)
                .filter_map do |address|
                  if !address.fixed? || address.offset.present?
                    {
                      pool_id: address.address_pool&.slug,
                      mode: address.mode,
                      connection: address.connection?,
                      address: nil,
                      dns_enabled: nil,
                      gateway: nil
                    }.tap do |hash|
                      if address.fixed?
                        hash[:address] = address.ip_object(sequential_number, team_number).to_string
                        hash[:dns_enabled] = address.dns_enabled
                      end
                      if nic.egress? && (address.mode_ipv4_static? || address.mode_ipv6_static?)
                        hash[:gateway] = address.address_pool.gateway_ip(team_number)&.to_s
                      end
                    end
                  end
                end
            }
          end
        end

        def checks
          Current.services_cache ||= {}
          Current.services_cache[spec.id] ||= Check
            .joins(:service)
            .merge(Service.for_spec(spec))
            .flat_map(&:slugs)
            .map(&:last)
          Current.services_cache[spec.id].map do |check_name|
            {
              id: check_name,
              budget_id: "#{spec.slug}_#{check_name}",
              exercise_unique_id: "#{inventory_name}_#{check_name}"
            }
          end
        end

        def tags
          GenerateTags.result_for(self).map { |tag| tag[:id] }
        end

        def connection_address
          (connection_nic&.addresses || []).detect(&:connection?)
        end
    end
  end
end
