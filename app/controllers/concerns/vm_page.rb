# frozen_string_literal: true

module VmPage
  extend ActiveSupport::Concern

  included do
    before_action :preload_form_collections
  end

  private
    def preload_form_collections
      @teams = policy_scope(Team).load_async
      @system_owners = policy_scope(User).order(:name).load_async
      @capabilities = policy_scope(@exercise.capabilities).load_async
      @services = policy_scope(@exercise.services).load_async
    end
end
