# frozen_string_literal: true

class ServiceCheck < ApplicationRecord
  include VmCacheBuster
  has_paper_trail

  belongs_to :service, touch: true
  belongs_to :network
  has_one :exercise, through: :service
  has_many :customization_specs, through: :service

  enum protocol: {
    tcp: 0,
    udp: 1,
    tcp_and_udp: 2,
    icmp: 3,
    sctp: 4
  }, _prefix: :protocol

  enum ip_family: {
    v4v6: 0,
    v4: 1,
    v6: 2
  }, _prefix: :ip_family

  def self.to_icon
    'fa-flask'
  end

  def display_name
    "#{I18n.t("protocols.#{protocol}")} (#{I18n.t("ip_families.#{ip_family}")}): #{destination_port}"
  end

  def slug
    [
      service.name,
      network.abbreviation,
      ip_family,
      protocol,
      destination_port
    ].compact.join '-'
  end

  def virtual_checks
    return [self] unless ip_family_v4v6?
    [
      self.dup.tap { |a| a.network = self.network; a.service = self.service; a.ip_family = 'v4' },
      self.dup.tap { |a| a.network = self.network; a.service = self.service; a.ip_family = 'v6' }
    ]
  end
end
