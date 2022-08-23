# frozen_string_literal: true

if ENV['SENTRY_DSN']
  Sentry.init do |config|
    config.dsn = ENV['SENTRY_DSN']
    config.send_default_pii = true
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]

    config.environment = ENV['SENTRY_ENV']
    config.enabled_environments = ['production', ENV['SENTRY_ENV']]

    config.traces_sample_rate = 0.5
  end
end
