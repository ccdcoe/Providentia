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

  before_save :network_change_cleanup
  after_save :update_vm_deploy_mode, if: :saved_change_to_network_id?

  validate :network_in_exercise

  scope :egress, -> { where(egress: true) }
  scope :connectable, -> { joins(:addresses).where(addresses: { connection: true }) }

  delegate :api_short_name, to: :network

  def self.to_icon
    'fa-network-wired'
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

    def network_change_cleanup
      return unless persisted? && network_id_changed?
      addresses.update_all offset: nil, address_pool_id: nil
      addresses.each(&:save) # will set correct addresspool
    end

    def update_vm_deploy_mode
      virtual_machine.update deploy_mode: 'bt' if network.numbered?
    end
end
