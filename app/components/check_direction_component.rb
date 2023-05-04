# frozen_string_literal: true

class CheckDirectionComponent < ViewComponent::Base
  attr_reader :f, :disabled

  def initialize(check:, f:, disabled: false)
    @check = check
    @f = f
    @disabled = disabled
  end

  private
    def type_field_name
      "#{self.class::DIRECTION.to_s.downcase}_type"
    end

    def value_field_name
      "#{self.class::DIRECTION.to_s.downcase}_gid"
    end

    def collection
      {
        'Special' => CustomCheckSubject.all
      }.merge(
        Current.networks_cache.group_by { |network| "Networks: #{network.actor.name}" }
      ).merge(
        Current.vm_cache.group_by { |spec| "Customization specs: #{spec.virtual_machine.actor.name}" }
      )
    end

    def relation_icon
      @check.public_send("to_#{self.class::DIRECTION.to_s.downcase}_icon")
    end
end
