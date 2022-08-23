# frozen_string_literal: true

class NumberingTools
  def self.substitute(masked_string, number)
    return unless masked_string
    masked_string.dup.tap do |str|
      str.gsub!('###', number.to_s.rjust(3, '0'))
      str.gsub!('##', number.to_s.rjust(2, '0'))
      str.gsub!('#', number.to_s)
    end
  end

  def self.unsubstitute(template_string:, input:)
    return unless input.present?
    return input unless /#/.match?(template_string)
    input.dup.tap do |out|
      /^.*?(\#{1,3})/.match(template_string).tap do |match|
        next unless match

        out[Range.new(*match.offset(0), true)] = match[0]
      end
    end
  end
end
