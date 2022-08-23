# frozen_string_literal: true

class Ipv6Offset
  attr_reader :offset

  def initialize(offset)
    @offset = offset.to_i
    @hex = IPAddress::IPv6
      .parse_u128(@offset)
      .compressed
      .sub(/^::/, '')
  end

  def store_value
    offset.zero? ? nil : offset
  end

  def to_s
    @hex
  end

  def ==(other)
    offset == other&.offset
  end

  alias eql? ==

  class << self
    def dump(obj)
      return unless obj
      offset = self.new(IPAddress("::#{obj}").to_u128) if obj.is_a?(String)
      offset = self.new(obj) if obj.is_a?(Integer)
      offset = obj if obj.is_a?(self)
      offset.store_value
    end

    def load(obj)
      return unless obj
      self.new(obj)
    end
  end
end
