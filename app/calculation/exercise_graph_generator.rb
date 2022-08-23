# frozen_string_literal: true

require 'rgl/adjacency'
require 'rgl/dot'
require 'rgl/topsort'

class ExerciseGraphGenerator < Patterns::Calculation
  private
    def result
      @graph = RGL::DirectedAdjacencyGraph.new
      @visited_networks = Set.new

      if options.dig(:full_map)
        add_everything
      else
        add_hosts
      end

      # @graph.print_dotted_on
      @graph.write_to_graphic_file('pdf') if options.dig(:debug)
      @graph
    end

    def vm_scope
      subject
        .eager_load(:connection_nic, :addresses)
        .reject do |vm|
          vm.addresses.gateway.any?
        end
    end

    def add_hosts
      vm_scope.group_by(&:connection_nic).each do |nic, hosts|
        next unless nic
        hosts.each do |host|
          add_edge(host, nic.network)
        end

        add_network_to_graph(nic.network)
      end
    end

    def add_everything
      vm_scope.each do |host|
        host.network_interfaces.each do |nic|
          add_edge(host, nic.network)
          add_network_to_graph(nic.network)
        end
      end
    end

    def add_network_to_graph(network)
      return if network.gateway_hosts.empty? || @visited_networks.include?(network)

      current_gateways = network.gateway_hosts.to_a
      add_edge(network, current_gateways)

      Network
        .distinct
        .joins(:virtual_machines, :network_interfaces)
        .where(virtual_machines: { id: current_gateways.map(&:id) })
        .merge(NetworkInterface.egress.reorder(''))
        .order(:name)
        .each do |egress_network|
          if !options.dig(:full_map) && options.dig(:skip_single_hop_networks)
            next_graphable_nodes_for(egress_network).each do |nextnode|
              add_edge(current_gateways, nextnode)
            end
          else
            add_edge(current_gateways, egress_network)
            add_network_to_graph(egress_network)
          end
        end

      @visited_networks << network
    end

    def next_graphable_nodes_for(network)
      if network.virtual_machines.all? { |vm| vm.addresses.gateway.present? }
        @visited_networks << network

        network.gateway_hosts.flat_map do |gw|
          gw.network_interfaces.egress.flat_map do |nic|
            next_graphable_nodes_for(nic.network)
          end
        end
      else
        [network]
      end
    end

    def add_edge(src, dst)
      @graph.add_edge graph_key(src), graph_key(dst)
    end

    def graph_key(object)
      return object unless options.dig(:debug)
      case object
      when VirtualMachine
        "Host: #{object.name}"
      when Network
        "Network: #{object.slug}"
      when Array
        if object.size == 1
          graph_key(object.first)
        else
          "Grouped: #{object.map(&:name).join('|')}"
        end
      else
        "Unknown: #{object.inspect}"
      end
    end
end
