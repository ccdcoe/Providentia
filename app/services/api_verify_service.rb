# frozen_string_literal: true

class APIVerifyService < Patterns::Service
  attr_reader :token_value

  def initialize(token_value)
    @token_value = token_value
  end

  def call
    return unless token_value
    payload, _header = JWT.decode token_value, public_key, true, decode_opts
    User.from_external(
      uid: payload.dig('preferred_username'),
      email: payload.dig('email'),
      resources: resource_list(payload)
    )
  rescue JWT::DecodeError, JWT::InvalidIssuerError
  end

  private
    def public_key
      @@issuer_public_key ||= Oj.load(HTTP.get(Rails.configuration.oidc_issuer).to_s).dig('public_key')
      OpenSSL::PKey::RSA.new(
        Base64.decode64(@@issuer_public_key)
      )
    end

    def decode_opts
      {
        verify_iss: true,
        iss: Rails.configuration.oidc_issuer,
        algorithm: 'RS256'
      }
    end

    def resource_list(payload)
      case Rails.configuration.authorization_mode
      when 'scope'
        payload.dig('resurces')
      when 'resource_access'
        payload.dig(
          'resource_access',
          ENV.fetch('KEYCLOAK_CLIENT_ID', ''), 'roles'
        )
      end
    end
end
