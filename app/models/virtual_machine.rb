# frozen_string_literal: true

class VirtualMachine < ApplicationRecord
  has_paper_trail

  # TO BE REMOVED
  enum deploy_mode: {
    single: 0,
    bt: 1
  }, _prefix: :deploy_mode

  enum visibility: {
    public: 1,
    actor_only: 2
  }, _prefix: :visibility

  belongs_to :exercise
  belongs_to :team, optional: true # TEMPORARY, to be removed
  belongs_to :actor
  belongs_to :operating_system, optional: true
  belongs_to :system_owner, class_name: 'User', inverse_of: :owned_systems, optional: true
  belongs_to :numbered_actor, class_name: 'Actor', foreign_key: :numbered_by, inverse_of: :numbered_virtual_machines, optional: true
  has_many :network_interfaces, dependent: :destroy
  has_many :customization_specs, dependent: :destroy
  has_one :connection_nic, -> { connectable },
    class_name: 'NetworkInterface', foreign_key: :virtual_machine_id
  has_one :host_spec, -> { mode_host },
    class_name: 'CustomizationSpec', foreign_key: :virtual_machine_id

  has_many :networks, through: :network_interfaces
  has_many :addresses, through: :network_interfaces
  has_and_belongs_to_many :services,
    after_add: :invalidate_cache, after_remove: :invalidate_cache
  has_and_belongs_to_many :capabilities,
    after_add: :invalidate_cache, after_remove: :invalidate_cache

  accepts_nested_attributes_for :network_interfaces,
    reject_if: proc { |attributes| attributes.all? { |key, value| value.blank? || value == '0' } }

  scope :search, ->(query) {
    columns = %w{virtual_machines.name customization_specs.dns_name users.name operating_systems.name}
    left_outer_joins(:system_owner, :operating_system, :customization_specs)
      .where(
        columns
          .map { |c| "lower(#{c}) ilike :search" }
          .join(' OR '),
        search: "%#{query.downcase}%"
      )
      .group(:id)
  }

  validates :name, uniqueness: { scope: :exercise }, presence: true, length: { minimum: 1, maximum: 63 }, hostname: true
  validates :ram, numericality: true, inclusion: 1..200, allow_blank: true
  validates :cpu, numericality: { only_integer: true }, inclusion: 1..100, allow_blank: true
  validates :custom_instance_count, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, allow_blank: true
  validates_associated :network_interfaces
  validate :hostname_conflicts, :transfer_overlap_error

  before_validation :lowercase_fields
  after_create :create_default_spec
  after_update :sync_host_spec_name
  after_touch :ensure_nic_status

  def self.to_icon
    'fa-server'
  end

  def vm_name
    "#{exercise.abbreviation}_#{actor.abbreviation}_#{name}".downcase
  end

  def forced_numbering?
    networks.any?(&:numbered?)
  end

  def single_network_instances(presenter)
    if numbered_actor && connection_nic.network.numbered?
      1.upto(custom_instance_count || 1).map do |seq|
        presenter.new(host_spec, seq, nil)
      end
    else
      host_spec.deployable_instances(presenter)
    end
  end

  def deploy_count
    numbered_actor.presence ? numbered_actor.numbering[:entries].last.to_i : 1
  end

  private
    def lowercase_fields
      name.downcase! if name
    end

    def hostname_conflicts
      return unless network_interfaces.any?

      query = VirtualMachine
        .from(
          VirtualMachine
            .joins(:customization_specs)
            .select("virtual_machines.id, customization_specs.id as id2, coalesce(NULLIF(customization_specs.dns_name, ''), NULLIF(virtual_machines.name, '')) as composite_name")
            .where(id: (connection_nic&.network&.virtual_machine_ids || []) - [id])
        )
        .where('composite_name = ?', name)
        .exists?

      return unless query
      errors.add(:name, :hostname_conflict)
    end

    def transfer_overlap_error
      return unless custom_instance_count_changed?
      return unless addresses.each do |add|
        add.virtual_machine = self
        add.valid?
      end.any? { |a| a.errors.of_kind? :offset, :overlap }
      errors.add(:custom_instance_count, :invalid)
    end

    def invalidate_cache(_service_or_capability)
      touch
    end

    def sync_host_spec_name
      return unless name_previously_changed?
      host_spec.update(name:)
    end

    def has_unnumbered_nets?
      networks.any? { |net| !net.numbered? }
    end

    def ensure_nic_status
      return if network_interface_ids.empty?
      NetworkInterface.transaction do
        network_interfaces.first.update(egress: true) if network_interfaces.egress.empty?
        addresses.joins(:address_pool).mode_ipv4_static.update(connection: true) if network_interfaces.connectable.empty?
      end
    end

    def create_default_spec
      customization_specs.create(mode: 'host', name:)
    end
end
