# frozen_string_literal: true

module ServicePage
  extend ActiveSupport::Concern

  included do
    before_action :preload_collections
  end

  private
    def preload_collections
      Current.networks_cache = policy_scope(@exercise.networks)
        .order(:name)
        .includes(:actor)
        .load_async
      Current.vm_cache = policy_scope(@exercise.customization_specs)
        .order(:name)
        .includes(virtual_machine: :actor)
        .load_async
    end
end
