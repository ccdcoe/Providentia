# frozen_string_literal: true

class IPPickerComponent < ViewComponent::Base
  attr_reader :label

  def initialize(form:, field:, hosts: :all, label: true)
    @form = form
    @field = field
    @hosts = hosts
    @label = label
  end

  def render?
    address_pool.ip_v4? && address_pool.ip_network
  end

  private
    def collection
      address_ip_objects.map do |ip_object|
        address = address_for_ip_object(ip_object)
        [
          AddressValues.result_for(address) || liquid_template_shortening(
            UnsubstitutedAddress.result_for(ip_object, address_pool:)
          ),
          ip_object.u32 - address_pool.ip_network.network_u32 - 1
        ]
      end.sort_by(&:last).uniq
    end

    def address_ip_objects
      case @hosts
      when :available_for_object # for specific network interface
        AvailableIPBlock.result_for(
          address_pool,
          count: reserve_amount,
          without: nic.addresses.mode_ipv4_static.flat_map(&:all_ip_objects)
        )
      when :all
        address_pool.ip_network.hosts
      end
    end

    def address_pool
      @address_pool ||= case @form.object
                        when AddressPool
                          @form.object
                        when Address
                          @form.object.address_pool
                        when AddressPoolForm
                          @form.object.send(:resource)
      end
    end

    def network
      address_pool.network
    end

    def vm
      @form.object.virtual_machine
    end

    def nic
      @form.object.network_interface
    end

    def exercise
      address_pool.exercise
    end

    def reserve_amount
      if vm.custom_instance_count
        [vm.custom_instance_count, 1].max
      elsif !network.numbered?
        vm.deploy_count
      else
        1
      end
    end

    def liquid_template_shortening(text)
      LiquidReplacer.new(text).iterate do |variable_node|
        "[ #{variable_node.name.name} ]"
      end
    end

    def address_for_ip_object(ip_object)
      address_pool.addresses.build(network:, offset: ip_object.to_u32 - ip_object.network.to_u32 - 1)
    end
end
