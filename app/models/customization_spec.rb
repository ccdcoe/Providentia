# frozen_string_literal: true

class CustomizationSpec < ApplicationRecord
  include SpecCacheUpdater
  extend FriendlyId
  has_paper_trail
  acts_as_taggable_on :tags
  acts_as_taggable_tenant :tenant_id

  friendly_id :api_id, use: [:slugged, :scoped], scope: :virtual_machine

  enum mode: {
    host: 1,
    container: 2
  }, _prefix: :mode, _default: 'host'

  scope :for_api, -> {
    includes(
      {
        virtual_machine: [
          :system_owner,
          :actor,
          :operating_system,
          :host_spec,
          { connection_nic: [:network] },
          :exercise
        ]
      },
      :capabilities_customizationspecs,
      :capabilities
    )
  }

  belongs_to :virtual_machine, touch: true
  has_one :exercise, through: :virtual_machine
  has_and_belongs_to_many :capabilities,
    after_add: :invalidate_capability_cache, after_remove: :invalidate_capability_cache

  validates :name, uniqueness: { scope: :virtual_machine }, presence: true, length: { minimum: 1, maximum: 63 }, hostname: true
  validates :dns_name, length: { minimum: 1, maximum: 63, allow_blank: true }, hostname: { allow_blank: true }
  validate :hostname_conflicts

  before_validation :lowercase_fields

  def self.to_icon
    'fa-book'
  end

  def hostname
    dns_name.presence || default_dns_name
  end

  def role
    role_name.presence || default_role_name
  end

  def default_role_name
    if mode_host?
      virtual_machine.name
    else
      "#{virtual_machine.name}_#{name}"
    end
  end

  def default_dns_name
    if mode_host?
      virtual_machine.name
    else
      virtual_machine.host_spec.hostname || virtual_machine.name
    end
  end

  def deployable_instances(presenter = API::V3::InstancePresenter)
    generate_instance_array(:deploy_count)
      .product(generate_instance_array(:custom_instance_count))
      .map do |team_number, sequential_number|
        presenter.new(self, sequential_number, team_number)
      end
  end

  def tenant_id
    raise 'No exercise!' unless exercise
    "exercise_#{exercise.id}"
  end

  private
    def api_id
      case mode
      when 'host'
        virtual_machine.name
      when 'container'
        "#{virtual_machine.name}_#{name}"
      end
    end

    def generate_instance_array(method)
      Array.new([virtual_machine.public_send(method) || 1, 1].max) { |i| [nil, 1].include?(virtual_machine.public_send(method)) ? nil : i + 1 }
    end

    def should_generate_new_friendly_id?
      name_changed? || super
    end

    def invalidate_capability_cache(capability)
      touch
      virtual_machine.touch
      schedule_spec_cache_update(capability)
    end

    def lowercase_fields
      dns_name.downcase! if dns_name
      role_name.downcase! if role_name
    end

    def hostname_conflicts
      return unless dns_name.present? && virtual_machine.connection_nic.present?

      query = VirtualMachine
        .from(
          VirtualMachine
            .joins(:customization_specs)
            .select("virtual_machines.id, customization_specs.id as id2, coalesce(NULLIF(customization_specs.dns_name, ''), NULLIF(virtual_machines.name, '')) as composite_name")
            .where(id: (virtual_machine.connection_nic&.network&.virtual_machine_ids || []))
            .where.not('customization_specs.id' => self.id)
        )
        .where('composite_name = ?', hostname)
        .exists?

      return unless query
      errors.add(:dns_name, :hostname_conflict)
    end
end
