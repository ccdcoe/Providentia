# frozen_string_literal: true

class HostnameGenerator < Patterns::Calculation
  private
    def result
      hostname_sequence_suffix = '{{ seq }}' if virtual_machine.custom_instance_count.to_i > 1
      hostname_team_suffix = '{{ team_nr }}' if !virtual_machine.deploy_mode_single? && (!nic || !nic.network&.numbered?)

      sequences = [
        hostname_sequence_suffix,
        hostname_team_suffix
      ].compact
      hostname = "#{subject.hostname}#{sequences.join('_')}"
      domain = nic&.network&.full_domain.to_s.gsub(/#+/, '{{ team_nr }}')

      OpenStruct.new({
        hostname:,
        domain:,
        fqdn: "#{hostname}.#{domain}"
      })
    end

    def virtual_machine
      subject.virtual_machine
    end

    def nic
      options[:nic] || virtual_machine.connection_nic
    end
end
