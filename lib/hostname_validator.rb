# frozen_string_literal: true

class HostnameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    # check hyphen at end or start
    record.errors.add(attribute, :label_begins_or_ends_with_hyphen) if value =~ (/^[-]/i) || value =~ (/[-]$/)

    # check allowed chars
    record.errors.add(attribute, :invalid) unless /^[a-z0-9\-]+$/i.match?(value)
  end
end
