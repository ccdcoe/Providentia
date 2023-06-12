# frozen_string_literal: true

class Check < ApplicationRecord
  include VmCacheBuster

  has_paper_trail

  belongs_to :service, touch: true
  belongs_to :source, polymorphic: true
  belongs_to :destination, polymorphic: true
  has_one :exercise, through: :service

  enum protocol: Protocols.to_enum_hash, _prefix: :protocol

  enum ip_family: {
    v4v6: 0,
    v4: 1,
    v6: 2
  }, _prefix: :ip_family

  enum check_mode: {
    network: 1,
    special: 2
  }, _prefix: :check_mode

  def self.to_icon
    'fa-flask'
  end

  def source_gid
    source&.to_gid
  end

  def destination_gid
    destination&.to_gid
  end

  def to_source_icon
    relation_to_icon(source)
  end

  def to_destination_icon
    relation_to_icon(destination)
  end

  def direction
    Rails.cache.fetch([self.cache_key_with_version, 'direction']) do
      self_subject = CustomCheckSubject.find_by(meaning: 'self')
      case [source, destination]
      in [^self_subject, ^self_subject]
        :self
      in [*, ^self_subject]
        :in
      in [^self_subject, *]
        :out
      else
        :other
      end
    end
  end

  def display_name
    case check_mode
    when 'special'
      special_label
    when 'network'
      "#{I18n.t("protocols.#{protocol}")} (#{I18n.t("ip_families.#{ip_family}")}): #{port}"
    end
  end

  def slugs
    if check_mode_special?
      [[nil, slug_for_ip_family]]
    else
      applied_ip_families.map do |ip_family|
        [ip_family, slug_for_ip_family(ip_family)]
      end
    end
  end

  def relation_to_api_name(relation)
    case relation
    when CustomCheckSubject
      relation.api_name
    when Network, CustomizationSpec
      relation.slug
    end
  end

  private
    def relation_to_icon(relation)
      case relation
      when CustomCheckSubject
        relation.base_class.constantize.to_icon
      when Network, CustomizationSpec
        relation.class.to_icon
      end
    end

    def applied_ip_families
      case ip_family
      when 'v4v6'
        [:v4, :v6]
      else
        [ip_family]
      end
    end

    def slug_for_ip_family(family = nil)
      [
        service.slug,
        "src:#{relation_to_api_name(source)}",
        "dst:#{relation_to_api_name(destination)}",
        check_mode_network? ? "ip#{family}" : nil,
        check_mode_network? ? protocol : nil,
        check_mode_network? ? port : nil,
        check_mode_special? ? special_label : nil
      ].compact.join '-'
    end
end
