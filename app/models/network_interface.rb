# frozen_string_literal: true

class NetworkInterface < ApplicationRecord
  has_paper_trail

  default_scope { order(:created_at) }

  belongs_to :virtual_machine, touch: true
  belongs_to :network, touch: true
  has_many :addresses, dependent: :destroy

  delegate :exercise, to: :virtual_machine, allow_nil: true

  accepts_nested_attributes_for :addresses,
    reject_if: proc { |attributes| attributes.all? { |key, value| value.blank? || value == '0' } }

  before_save :clear_address_on_network_change
  after_save :update_vm_deploy_mode, if: :saved_change_to_network_id?

  validate :network_in_exercise

  scope :egress, -> { where(egress: true) }
  scope :connectable, -> { joins(:addresses).where(addresses: { connection: true }) }

  delegate :api_short_name, to: :network

  def self.to_icon
    'fa-network-wired'
  end

  def fqdn
    "#{hostname}.#{domain}"
  end

  def domain
    network.full_domain.gsub(/#+/, '{{ team_nr }}')
  end

  def hostname
    hostname_sequence_suffix = '{{ seq }}' if virtual_machine.custom_instance_count.to_i > 1
    hostname_team_suffix = '{{ team_nr }}' if !virtual_machine.deploy_mode_single? && !network&.numbered?

    sequences = [
      hostname_sequence_suffix,
      hostname_team_suffix
    ].compact

    "#{virtual_machine.actual_hostname}#{sequences.join('_')}"
  end

  def connection?
    addresses.any?(&:connection?)
  end

  private
    def network_in_exercise
      return unless network
      return if network.exercise == virtual_machine.exercise
      errors.add(:network, :invalid)
    end

    def clear_address_on_network_change
      return unless persisted? && network_id_changed?
      addresses.update_all offset: nil, address_pool_id: nil
    end

    def update_vm_deploy_mode
      virtual_machine.update deploy_mode: 'bt' if network.numbered?
    end
end
