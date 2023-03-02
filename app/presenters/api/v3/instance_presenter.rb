# frozen_string_literal: true

module API
  module V3
    class InstancePresenter < Struct.new(:spec, :sequential_number, :team_number)
      delegate :team,
        :operating_system,
        :deploy_mode, :deploy_mode_single?,
        to: :vm

      def as_json
        {
          id: inventory_name,
          vm_name:,
          team_unique_id: name,
          hostname:,
          domain: substitute(connection_namespec.domain.to_s),
          fqdn: substitute(connection_namespec.fqdn.to_s),
          connection_address: vm.addresses.find_by(connection: true)&.ip_object(sequential_number, team_number)&.address,
          interfaces: network_interfaces,
          checks:,
          config_map: {}
        }.merge(team_numbers).merge(sequence_info)
      end

      private
        def vm
          spec.virtual_machine
        end

        def connection_namespec
          @connection_namespec ||= HostnameGenerator.result_for(spec)
        end

        def substitute(text)
          StringSubstituter.result_for(
            text,
            {
              seq: sequential_number.to_s.rjust(2, '0'),
              team_nr: team_number.to_s.rjust(2, '0')
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
          't{{ team_nr }}' if !vm.deploy_mode_single?
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
          host_spec = HostnameGenerator.result_for(vm.host_spec)
          substitute("#{vm.exercise.abbreviation}_#{host_spec.fqdn}").downcase
        end

        def hostname
          substitute(
            HostnameGenerator.result_for(
              spec,
              nic: vm.network_interfaces.find { |nic| !nic.network.numbered? } ||
                vm.network_interfaces.first ||
                vm.dup.network_interfaces.build
            ).hostname
          )
        end

        def network_interfaces
          vm.network_interfaces.map do |nic|
            namespec = HostnameGenerator.result_for(spec, nic:)
            {
              network_id: nic.network.slug,
              cloud_id: substitute(nic.network.cloud_id.to_s),
              domain: substitute(nic.network.full_domain),
              fqdn: substitute(namespec.fqdn),
              egress: nic.egress?,
              connection: nic.addresses.any?(&:connection),
              addresses: nic.addresses.for_api.map do |address|
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
            }
          end
        end

        def checks
          spec
            .services
            .flat_map do |service|
              service.service_checks.flat_map(&:virtual_checks).map(&:slug) +
                service.special_checks.map(&:slug)
            end
            .map { |check_name|
              {
                id: check_name,
                budget_id: "#{spec.slug}_#{check_name}",
                exercise_unique_id: "#{inventory_name}_#{check_name}"
              }
            }
        end
    end
  end
end
