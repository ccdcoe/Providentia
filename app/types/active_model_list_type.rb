# frozen_string_literal: true

class ActiveModelListType < ActiveRecord::Type::Value
  attr_reader :klass

  #
  # List type Constructor
  #
  # @param [Class] klass The class for which this list type is declared.
  #
  def initialize(klass)
    @klass = klass
  end

  # Type casts a value from user input (e.g. from a setter). This value may
  # be a string from the form builder, or a ruby object passed to a setter.
  #
  # @param [klass, Hash, Array<klass,Hash>] value The value to cast.
  #
  # @return [Array<klass>] The list of values that must be actually set on the parent attribute.
  #
  def cast(value)
    [value].flatten.map { |e| e.is_a?(klass) ? e : klass.new(e) }
  end

  # Casts a value from the ruby type to a type that the database knows how
  # to understand.
  #
  # In our case we want to convert an array of objects to
  #
  # @param [Array<klass>] model_list The list of klass records.
  #
  # @return [Array<Hash>] The list of values that must be actually set on the parent attribute.
  #
  def serialize(model_list)
    model_list.map(&:attributes).to_json
  end

  # Converts a value from database input to the appropriate ruby type.
  #
  # @param [String] db_value The database json string.
  #
  # @return [Array<klass>] The list of values that must be actually set on the parent attribute.
  #
  def deserialize(db_value)
    JSON.parse(db_value).map { |e| klass.new(e) }
  end

  # Determines whether the mutable value has been modified since it was
  # read. It is used to detect changes and whether the parent model should be
  # saved.
  #
  # @param [String] raw_old_value The original value, before being passed to deserialize
  # @param [String] new_value The current value, after type casting.
  #
  # @return [Boolean] True if the collection was changed.
  #
  def changed_in_place?(raw_old_value, new_value)
    deserialize(raw_old_value) != new_value
  end
end
