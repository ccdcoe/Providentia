# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

# end
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :none
    policy.base_uri    :none
    policy.font_src    :self
    policy.style_src   :self
    policy.img_src     :self, :https, :data
    policy.script_src  :self
    policy.manifest_src :self

    if Rails.env.development?
      policy.connect_src :self, :https, 'ws://localhost:8082'
    else
      policy.connect_src :self
    end
  end

  # Generate session nonces for permitted importmap and inline scripts
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w(style-src script-src)

  # Report CSP violations to a specified URI. See:
  # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
  # config.content_security_policy_report_only = true
end
