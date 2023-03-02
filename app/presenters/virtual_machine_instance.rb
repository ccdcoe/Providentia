# frozen_string_literal: true

class VirtualMachineInstance < Struct.new(:spec, :sequential_number, :team_number)
  delegate :name, :team,
    :operating_system,
    :deploy_mode, :deploy_mode_single?,
    :connection_nic,
    to: :vm

  def hostname
    @hostname ||= computed_hostname(spec.hostname)
  end

  def inventory_name
    @inventory_name ||= computed_hostname(name).dup.tap do |str|
      if team_number && !add_team_to_hostname?
        str << "_#{team_number.to_s.rjust(2, '0')}"
      end
    end
  end

  def cpu
    vm.cpu || vm.operating_system&.applied_cpu
  end

  def ram
    ram_size = vm.ram || vm.operating_system&.applied_ram
    return unless ram_size
    ram_size * 1024
  end

  def numbered_domain
    @numbered_domain ||= NumberingTools.substitute(connection_nic.network.full_domain, team_number)
  end

  def sequential_group
    return unless vm.custom_instance_count.to_i > 1
    "sequential_#{vm.name}".tr('-', '_')
  end

  def to_ansible_acceptable_format
    {
      id: name,
      name: inventory_name,
      owner: vm.system_owner&.name,
      description: vm.description,
      team: {
        name: team.name.downcase,
        bt_visible: vm.api_bt_visible
      },
      capabilities:,
      vars: ({
        id: name,
        role: spec.role,
        hostname:,
        cpus: cpu,
        ram:,
        networks: networks.map(&:compact),
        }.tap do |inner_json|
          if vm.custom_instance_count.to_i > 1
            inner_json[:sequential_group] = sequential_group
            inner_json[:sequential_index] = sequential_number
            inner_json[:sequential_count] = vm.custom_instance_count
          end
          if connection_nic && !deploy_mode_single?
            inner_json[:domain] = numbered_domain
          end
          if team_number
            inner_json[:team_nr_x] = team_number
            inner_json[:team_nr_xx] = team_number.to_s.rjust(2, '0')
          end
        end).compact,
      groups: groups.compact,
      services:
    }
  end

  def networks
    @networks ||= vm.network_interfaces.select(&:persisted?).map do |nic|
      network_hash(nic)
    end
  end

  private
    def vm
      spec.virtual_machine
    end

    def add_team_to_hostname?
      vm.networks.any? { |net| !net.numbered? } && team_number
    end

    def computed_hostname(source)
      source.dup.tap do |str|
        if sequential_number
          str << sequential_number.to_s.rjust(2, '0')
        elsif connection_nic && add_team_to_hostname?
          str << team_number.to_s.rjust(2, '0')
        end
      end
    end

    def network_hash(nic)
      addresses = nic.addresses.group_by(&:mode)
      ipv4 = addresses.dig('ipv4_static', 0)&.ip_object(sequential_number, team_number)
      ipv6 = addresses.dig('ipv6_static', 0)&.ip_object(sequential_number, team_number)

      {
        connection_name: "Link to #{nic.network.abbreviation}",
        name: NumberingTools.substitute(nic.network.cloud_id.to_s, team_number),
        ipv4: ipv4&.to_string,
        ipv6: ipv6&.to_string,
        domain: NumberingTools.substitute(nic.network.full_domain, team_number),
        dns_enabled: nic.addresses.any?(&:dns_enabled?),
        no_address: nic.addresses.empty?
      }.tap do |network|
        if vm.network_interfaces.egress.include?(nic)
          ipv4_gateway = addresses.dig('ipv4_static', 0)&.address_pool&.gateway_ip(team_number)
          ipv6_gateway = addresses.dig('ipv6_static', 0)&.address_pool&.gateway_ip(team_number)

          network[:ipv4_gateway] = ipv4_gateway&.address    unless ipv4 == ipv4_gateway
          network[:ipv6_gateway] = ipv6_gateway&.compressed unless ipv6 == ipv6_gateway
        end
      end
    end

    def groups
      [
        sequential_group,
        connection_nic&.api_short_name,
        operating_system&.api_v2_short_name,
        team.api_short_name,
        ("#{team.api_short_name}_#{deploy_mode}_numbered" if !deploy_mode_single? && !team.blue?)
      ].compact
    end

    def services
      vm.host_spec.services.map do |service|
        {
          name: service.name,
          checks: all_checks(service)
        }
      end
    end

    def all_checks(service)
      network_checks(service) + special_checks(service)
    end

    def network_checks(service)
      service.service_checks.flat_map(&:virtual_checks).map do |check|
        {
          id: "#{computed_hostname(name)}-#{check.slug}",
          source_network: NumberingTools.substitute(check.network.cloud_id.to_s, team_number),
          protocol: check.protocol,
          ip: check.ip_family,
          port: check.destination_port
        }
      end
    end

    def special_checks(service)
      service.special_checks.map do |check|
        {
          id: "#{computed_hostname(name)}-#{check.slug}",
          source_network: NumberingTools.substitute(check.network.cloud_id.to_s, team_number),
          name: check.name
        }
      end
    end

    def capabilities
      Capability.where(
        id: vm.host_spec.capability_ids + connection_nic&.network&.capability_ids.to_a
      ).pluck(:slug)
    end
end
