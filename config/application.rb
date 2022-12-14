# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Providentia
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.eager_load_paths += %w[lib/]

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # enable load_async
    config.active_record.async_query_executor = :global_thread_pool

    # Don't generate system test files.
    config.generators.system_tests = nil

    config.resource_prefix = ENV.fetch('RESOURCE_PREFIX', '')
    config.oidc_issuer = ENV.fetch('OIDC_ISSUER', '')
    config.authorization_mode = ENV.fetch('AUTH_MODE', 'scope')
  end
end
