# frozen_string_literal: true

class CheckListComponent < ViewComponent::Base
  attr_reader :direction, :checks

  def initialize(direction:, checks:)
    @direction = direction
    @checks = checks
  end

  private
    def direction_icon
      case direction
      when :in
        'fa-right-to-bracket'
      when :out
        'fa-right-from-bracket'
      when :self
        'fa-rotate-right'
      end
    end

    def direction_text
      case direction
      when :in
        'incoming'
      when :out
        'outgoing'
      when :self
        'self-check'
      when :other
        'other'
      end
    end

    def direction_relation
      case direction
      when :in
        :source
      when :out
        :destination
      end
    end

    def actor_for(check)
      relation_for(check).tap do |relation|
        return if !relation || !relation.respond_to?(:actor)
      end.actor
    end

    def relation_for(check)
      return unless direction_relation
      check.public_send(direction_relation)
    end
end
