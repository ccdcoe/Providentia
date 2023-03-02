# frozen_string_literal: true

class UnsubstitutedAddress < Patterns::Calculation
  attr_reader :network, :ip_object, :process_method, :template_string

  private
    def result
      return unless subject
      case subject
      when Address
        prepare_address
      when IPAddress
        prepare_ip_address
      end

      process
    end

    def prepare_address
      @ip_object = subject.ip_object
      @network = subject.ip_family_network
      @template_string = subject.ip_family_network_template.to_s.partition('/').first
    end

    def prepare_ip_address
      @ip_object = subject
      @network = options[:address_pool].ip_network
      @template_string = options[:address_pool].network_address.to_s.partition('/').first
    end

    def process
      NumberingTools.unsubstitute(
        template_string:, input: substitution_step
      )
    end

    def substitution_step
      template_string.dup.tap do |template|
        template.sub!('::', ':') if template.match?(/(:.*){6}::/) # ipv6, yay
      end.rpartition('}}').tap do |template_parts|
        template_parts[-1] = ip_object.to_s.partition(
          network.to_s.rpartition(
            template_parts.last
          ).first
        ).last
      end.join ''
    end
end
