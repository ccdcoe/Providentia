# frozen_string_literal: true

class OperatingSystem < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged, sequence_separator: '_'

  has_paper_trail
  has_ancestry

  has_many :virtual_machines

  scope :search, ->(query) {
    columns = %w{name}
    where(
      columns
        .map { |c| "#{c} ilike :search" }
        .join(' OR '),
      search: "%#{query}%")
      .group(:id)
  }

  validate :cpu_present_in_path, :ram_present_in_path, :primary_disk_size_present_in_path
  validates :cloud_id, uniqueness: true
  validates :name, presence: true

  before_save :ensure_cloud_id
  after_save :update_virtual_machines

  def self.to_icon
    'fa-hdd'
  end

  def applied_cpu
    self.cpu || parent&.applied_cpu
  end

  def applied_ram
    self.ram || parent&.applied_ram
  end

  def applied_primary_disk_size
    self.primary_disk_size || parent&.applied_primary_disk_size
  end

  def to_icon
    case slug
    when /ubuntu/
      'fa-brands fa-ubuntu'
    when /win/
      'fa-brands fa-windows'
    else
      'fa-solid fa-server'
    end
  end

  def api_short_name
    "os_#{friendly_id}"
  end

  def normalize_friendly_id(string)
    super.tr('-', '_')
  end

  def downcased_name
    name.downcase
  end

  private
    def ensure_cloud_id
      self.cloud_id ||= self.friendly_id
    end

    def cpu_present_in_path
      return if self.is_root?
      errors.add(:cpu, :missing_in_path) unless applied_cpu.present?
    end

    def ram_present_in_path
      return if self.is_root?
      errors.add(:ram, :missing_in_path) unless applied_ram.present?
    end

    def primary_disk_size_present_in_path
      return if self.is_root?
      errors.add(:primary_disk_size, :missing_in_path) unless applied_primary_disk_size.present?
    end


    def update_virtual_machines
      virtual_machines.each(&:touch)
    end

    def should_generate_new_friendly_id?
      name_changed? || super
    end
end
