# frozen_string_literal: true

class ActorNumberConfig < ApplicationRecord
  belongs_to :actor, touch: true
  has_many :numbered_virtual_machines, class_name: 'VirtualMachine', as: :numbered_by

  validates :name, presence: true

  before_save :remove_empty_matchers, :stringify_matchers

  scope :for_number, ->(nr) {
    where('matcher @> :nr::jsonb', nr: [nr.to_s].to_json)
  }

  private
    def remove_empty_matchers
      matcher.reject!(&:blank?)
    end

    def stringify_matchers
      matcher.map!(&:to_s)
    end
end
