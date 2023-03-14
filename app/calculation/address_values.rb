# frozen_string_literal: true

class AddressValues < Patterns::Calculation
  def result
    if subject.address_pool&.last_octet_is_dynamic? && subject.network.actor.numbering
      values = subject.network.actor
        .numbering[:entries]
        .values_at(0, 1, -1)
        .uniq
        .map { |number| subject.ip_object(nil, number).to_s }

      case values.size
      when 2
        "(#{values[0]} - #{values[1]})"
      else
        "(#{values[0]}, #{values[1]} ... #{values[2]})"
      end
    end
  end
end
