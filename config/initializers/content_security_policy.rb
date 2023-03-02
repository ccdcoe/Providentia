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
    policy.style_src   :self, :unsafe_inline # needed for codemirror
    # Allow @vite/client to hot reload style changes in development
    # policy.style_src(*policy.style_src, :unsafe_inline) if Rails.env.development?

    policy.img_src     :self, :https, :data
    policy.script_src  :self
    # Allow @vite/client to hot reload javascript changes in development
    policy.script_src(*policy.script_src, :unsafe_eval, "http://#{ ViteRuby.config.host_with_port }", 'ws://providentia.localhost:3036') if Rails.env.development?

    # You may need to enable this in production as well depending on your setup.
    # policy.script_src *policy.script_src, :blob if Rails.env.test?

    policy.manifest_src :self
    policy.connect_src :self
    # Allow @vite/client to hot reload changes in development
    policy.connect_src(*policy.connect_src, "ws://#{ ViteRuby.config.host_with_port }", 'ws://providentia.localhost:3036') if Rails.env.development?
  end

  # Generate session nonces for permitted importmap and inline scripts
  unless Rails.env.development?
    config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
    # config.content_security_policy_nonce_directives = %w(style-src script-src)
    config.content_security_policy_nonce_directives = %w(script-src)
  end

  # Report CSP violations to a specified URI. See:
  # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
  # config.content_security_policy_report_only = true
end
