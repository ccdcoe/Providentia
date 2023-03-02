# frozen_string_literal: true

class AddressValues < Patterns::Calculation
  def result
    if subject.address_pool.last_octet_is_dynamic?
      values = subject.exercise
        .all_blue_teams
        .values_at(0, 1, -1)
        .uniq
        .map { |team| subject.ip_object(nil, team).to_s }

      case values.size
      when 2
        "(#{values[0]} - #{values[1]})"
      else
        "(#{values[0]}, #{values[1]} ... #{values[2]})"
      end
    end
  end
end
