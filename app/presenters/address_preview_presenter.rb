# frozen_string_literal: true

class AddressPreviewPresenter < Struct.new(:vm, :sequential_number, :team_number)
  def name
    substitute(vm.connection_nic&.fqdn.to_s)
  end

  def interfaces
    vm.network_interfaces.map do |nic|
      {
        name: nic.network.name,
        addresses: nic.addresses.for_api.map do |address|
          {
            mode: address.mode,
          }.tap do |hash|
            if address.fixed?
              hash[:address] = address.ip_object(sequential_number, team_number).to_string
            end
          end
        end
      }
    end
  end

  private
    def substitute(text)
      StringSubstituter.result_for(
        text,
        {
          seq: sequential_number.to_s.rjust(2, '0'),
          team_nr: team_number.to_s.rjust(2, '0')
        }
      )
    end
end
