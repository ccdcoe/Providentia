# frozen_string_literal: true

class User < ApplicationRecord
  has_many :owned_systems, class_name: 'VirtualMachine', foreign_key: :system_owner_id
  has_many :api_tokens

  devise :trackable, :omniauthable, omniauth_providers: %i[sso]

  scope :admins, -> { where("permissions -> 'admin' = 'true'") }
  scope :for_exercise, ->(exercise) {
    admins.or(
      where('permissions ?| array[:keys]', keys: [exercise.id.to_s])
    )
  }

  def self.from_external(uid:, email:, resources:, extra_fields: {})
    permissions = UserPermissions.result_for(resources)
    return unless permissions

    user = find_by(uid: uid) || find_by(email: email)
    user ||= create(uid: uid)
    user.update({
      uid: uid,
      email: email || "",
      permissions: permissions
    }.merge(extra_fields))
    user
  end

  def initials
    name
      .split(' ', 2)
      .map(&:first)
      .join('')
      .upcase
  end

  def admin?
    permissions['admin']
  end

  def accessible_exercises
    permissions.except('admin').tap do |hash|
      hash.default = []
    end
  end
end
