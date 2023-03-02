# frozen_string_literal: true

module PaperTrail
  class Version < ActiveRecord::Base
    include PaperTrail::VersionConcern

    belongs_to :item, polymorphic: true, counter_cache: false

    def self.policy_class
      VersionPolicy
    end

    def to_partial_path
      'versions/version'
    end

    def user
      return User.new(name: 'SYSTEM') unless whodunnit
      User.find(whodunnit)
    end

    def full_name
      if item.respond_to? :virtual_machine
        "#{name} on VM #{item.virtual_machine.name} (#{item.virtual_machine.exercise.abbreviation})"
      elsif item.respond_to? :exercise
        "#{name} (#{item.exercise.abbreviation})"
      else
        name
      end
    end

    def name
      if item.respond_to? :name
        "#{item_class.model_name.human} #{item.name}"
      else
        "#{item_class.model_name.human} #{item_id}"
      end
    end

    def item_class
      item_type.constantize
    end
  end
end
