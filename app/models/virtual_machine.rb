# frozen_string_literal: true

class VirtualMachine < ApplicationRecord
  has_paper_trail

  enum deploy_mode: {
    single: 0,
    bt: 1
  }, _prefix: :deploy_mode

  belongs_to :team
  belongs_to :exercise
  belongs_to :operating_system, optional: true
  belongs_to :system_owner, class_name: 'User', inverse_of: :owned_systems, optional: true
  has_many :network_interfaces, dependent: :destroy
  has_one :connection_nic, -> { connectable },
    class_name: 'NetworkInterface', foreign_key: :virtual_machine_id

  has_many :networks, through: :network_interfaces
  has_many :addresses, through: :network_interfaces
  has_and_belongs_to_many :services,
    after_add: :invalidate_cache, after_remove: :invalidate_cache
  has_and_belongs_to_many :capabilities,
    after_add: :invalidate_cache, after_remove: :invalidate_cache

  accepts_nested_attributes_for :network_interfaces,
    reject_if: proc { |attributes| attributes.all? { |key, value| value.blank? || value == '0' } }

  scope :for_team, ->(team) { where(team: team) }
  scope :search, ->(query) {
    columns = %w{virtual_machines.name virtual_machines.hostname users.name operating_systems.name}
    left_outer_joins(:system_owner, :operating_system)
      .where(
        columns
          .map { |c| "lower(#{c}) like :search" }
          .join(' OR '),
        search: "%#{query.downcase}%"
      )
  }

  validates :name, uniqueness: { scope: :exercise }, presence: true, length: { minimum: 1, maximum: 63 }, hostname: true
  validates :hostname, length: { minimum: 1, maximum: 63, allow_blank: true }, hostname: { allow_blank: true }
  validates :ram, numericality: true, inclusion: 1..200, allow_blank: true
  validates :cpu, numericality: { only_integer: true }, inclusion: 1..100, allow_blank: true
  validates :custom_instance_count, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, allow_blank: true
  validates_associated :network_interfaces
  validate :hostname_conflicts, :transfer_overlap_error

  before_save :lowercase_ansible_fields, :reset_bt_visibility
  after_touch :ensure_nic_status

  def self.to_icon
    'fa-server'
  end

  def vm_name
    "#{exercise.abbreviation}_#{team.abbreviation}_#{name}".downcase
  end

  def forced_bt_numbering?
    networks.any?(&:numbered?)
  end

  def deployable_instances(presenter = VirtualMachineInstance)
    generate_instance_array(:deploy_count)
      .product(generate_instance_array(:custom_instance_count))
      .map do |team_number, sequential_number|
        presenter.new(self, sequential_number, team_number)
      end
  end

  def single_network_instances(presenter = VirtualMachineInstance)
    if !deploy_mode_single? && connection_nic.network.numbered?
      generate_instance_array(:custom_instance_count).map do |seq|
        presenter.new(self, seq, nil)
      end
    else
      deployable_instances(presenter)
    end
  end

  def deploy_count
    case deploy_mode.to_sym
    when :bt
      exercise.last_dev_bt
    else
      1
    end
  end

  def actual_hostname
    hostname.presence || name
  end

  def api_bt_visible
    case team.name.downcase
    when 'blue'
      true
    when 'green'
      bt_visible
    else
      false
    end
  end

  private
    def generate_instance_array(method)
      Array.new([public_send(method) || 1, 1].max) { |i| [nil, 1].include?(public_send(method)) ? nil : i + 1 }
    end

    def lowercase_ansible_fields
      name.downcase! if name
      hostname.downcase! if hostname
      role.downcase! if role
    end

    def hostname_conflicts
      return unless network_interfaces.any?

      query = VirtualMachine
        .from(
          VirtualMachine
            .select("id, coalesce(NULLIF(hostname, ''), NULLIF(name, '')) as composite_name")
            .where(id: (connection_nic&.network&.virtual_machine_ids || []) - [id])
        )
        .where('composite_name = ?', actual_hostname)
        .exists?

      return unless query
      errors.add(hostname.present? ? :hostname : :name, :hostname_conflict)
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

    def reset_bt_visibility
      return unless team_id_changed? && team_id_was == Team.find_by(name: 'Green')&.id
      self.bt_visible = true
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
end
