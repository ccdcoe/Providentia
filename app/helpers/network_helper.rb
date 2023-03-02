# frozen_string_literal: true

module NetworkHelper
  def sorted_used_addresses(network)
    network.addresses.for_used_addresses.group_by(&:virtual_machine).map do |vm, addresses|
      [
        vm,
        addresses
          .sort_by(&:offset)
          .group_by(&:ip_family)
          .reverse_merge({ ipv4: [], ipv6: [] })
      ]
    end.sort_by do |_vm, addresses|
      (addresses[:ipv4] + addresses[:ipv6])
        .reject(&:vip?)
        .compact
        .first
        &.offset
        &.to_i || -1
    end
  end
end
