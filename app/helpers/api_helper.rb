# frozen_string_literal: true

module APIHelper
  def common_vars
    {
      vars: {
        team_numbers_X: @exercise.all_blue_teams,
        team_numbers_XX: @exercise.all_blue_teams.map { |number| number.to_s.rjust(2, '0') },
        dev_teams: @exercise.dev_blue_teams,
        domain: @exercise.root_domain
      }
    }
  end

  def hosts
    Rails.cache.fetch(['apiv2', @exercise, 'hosts', vm_cache_key]) do
      machine_instances.flat_map do |instance|
        Rails.cache.fetch([
            'apiv2',
            @exercise,
            'host',
            instance.spec,
            instance.spec.virtual_machine,
            instance.sequential_number,
            instance.team_number
          ]) do
          instance.to_ansible_acceptable_format
        end
      end
    end
  end

  def sequential_groups
    Rails.cache.fetch(['apiv2', @exercise, 'seq_groups', vm_cache_key]) do
      machine_instances
        .map(&:sequential_group)
        .uniq
        .compact
        .map do |group_name|
          { name: group_name, vars: {}, children: [] }
        end
    end
  end

  def network_groups
    Rails.cache.fetch(['apiv2', @exercise, vm_cache_key, network_cache_key]) do
      virtual_machines.group_by(&:connection_nic).filter_map do |nic, instances|
        next unless nic

        {
          name: nic.api_short_name,
          vars: {},
          children: [],
        }.tap do |group|
          group[:vars][:domain] = nic.network.full_domain unless nic.network.numbered?
        end
      end
    end
  end

  def os_groups
    Rails.cache.fetch(['apiv2', @exercise, "os_#{OperatingSystem.all.cache_key_with_version}"]) do
      OperatingSystem.all.map do |os|
        {
          name: os.api_v2_short_name,
          vars: {},
          children: os.children.map(&:api_v2_short_name)
        }
      end
    end
  end

  def team_groups
    Rails.cache.fetch(['apiv2', @exercise, "os_#{Team.all.cache_key_with_version}"]) do
      Team.all.map do |team|
        {
          name: team.api_short_name,
          vars: {
            team_color: team.name,
          },
          children: [],
        }
      end
    end
  end

  def numbered_team_groups
    Rails.cache.fetch(['apiv2', @exercise, 'num_groups', vm_cache_key]) do
      machine_instances
        .reject(&:deploy_mode_single?)
        .group_by { |instance| [instance.team, instance.deploy_mode] }
        .filter_map do |group, instances|
          team, mode = group
          next if team.blue?
          {
           name: "#{team.api_short_name}_#{mode}_numbered",
            vars: {},
            children: [],
          }
        end
    end
  end
end
