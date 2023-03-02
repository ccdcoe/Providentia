# frozen_string_literal: true

class NetworkMapGraphSerializer < Patterns::Calculation
  class Presenter < ::API::V3::InstancePresenter
    def to_node
      {
        id: inventory_name,
        name: hostname,
        team: {
          name: vm.team.name,
          ui_color: vm.team.ui_color
        },
        addresses: vm.connection_nic.addresses.for_search.map do |address|
          LiquidReplacer.new(
            UnsubstitutedAddress.result_for(
              address.ip_object(sequential_number, team_number),
              address_pool: address.address_pool
            )
          ).iterate do |variable_node|
            if variable_node.name.name == 'team_nr'
              "[#{vm.exercise.all_blue_teams.values_at(0, -1).map do |team|
                variable_node.render(Liquid::Context.new('team_nr' => team.to_s))
              end.join(' - ')}]"
            end
          end
        end,
        os: {
          name: vm.operating_system&.name,
          icon: (vm.operating_system.presence || OperatingSystem.new).to_icon
        },
        classes: 'host'
      }
    end
  end

  private
    def result
      @groups = Set.new
      @nodes = Set.new
      @edges = Set.new

      build_graph

      {
        groups: @groups.reject(&:blank?),
        nodes: @nodes.reject(&:blank?).sort_by { |a| a[:name] },
        edges: @edges.reject { |edge| edge.any?(&:blank?) }
      }
    end

    def build_graph
      subject.each do |node|
        case node
        when VirtualMachine
          add_host(node)
        when Network
          @groups << { id: map_id_from_object(node), name: node.name, classes: 'segment' }

          add_edges(node)
        when Array
          @groups << {
            id: map_id_from_object(node),
            name: map_name_from_object(node),
            classes: 'egress'
          }

          node.select { |component| component.is_a?(VirtualMachine) }.each do |gw|
            add_host(gw, node)
          end

          add_edges(node)
        end
      end
    end

    def add_edges(source)
      subject.each_adjacent(source) do |target|
        @edges << {
          source: map_id_from_object(source),
          target: map_id_from_object(target),
          classes: source.class == target.class ? 'same' : 'notsame'
        }
      end
    end

    def add_host(host, parent = nil)
      host.single_network_instances(Presenter).each do |instance|
        @nodes << instance.to_node.merge(
          parent: map_id_from_object(parent || host.connection_nic.network)
        )
      end
    end

    def map_id_from_object(object)
      case object
      when Array
        object.map { |sub| 'e' + map_id_from_object(sub) }.join(' & ')
      when VirtualMachine
        'host' + object.name
      when Presenter
        raise 'asd'
      when Network
        'net' + object.slug
      end
    end

    def map_name_from_object(object)
      case object
      when Array
        object.map { |sub| map_name_from_object(sub) }.join(' & ')
      when VirtualMachine
        object.name
      when Presenter
        raise 'blah'
      when Network
        object.slug
      end
    end
end
