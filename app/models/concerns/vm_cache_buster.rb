# frozen_string_literal: true

module VmCacheBuster
  extend ActiveSupport::Concern

  included do
    before_destroy :update_virtual_machines
    after_save :update_virtual_machines
  end

  private
    def update_virtual_machines
      virtual_machines.each(&:touch)
    end
end
