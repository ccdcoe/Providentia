# frozen_string_literal: true

module API
  module V3
    class ServicePresenter < Struct.new(:service, :spec_scope)
      def as_json(_opts)
        Rails.cache.fetch(['apiv3', service.cache_key_with_version]) do
          {
            id: service.slug,
            name: service.name,
            subjects:,
            checks:
          }
        end
      end

      private
        def checks
          service.checks.flat_map do |check|
            check.slugs.map do |ip_family, slug|
              {
                id: slug,
                source_type: relation_type_for_api(check.source),
                source_id: check.relation_to_api_name(check.source),
                destination_type: relation_type_for_api(check.destination),
                destination_id: check.relation_to_api_name(check.destination),
                scored: check.scored,
                protocol: check.check_mode_network? ? check.protocol : nil,
                ip: check.check_mode_network? ? ip_family : nil,
                port: check.check_mode_network? ? check.port : nil,
                special_label: check.check_mode_special? ? check.special_label : nil,
                config_map: check.check_mode_special? ? check.config_map : nil,
              }
            end
          end
        end

        def subjects
          spec_scope
            .where(id: service.cached_spec_ids)
            .order(:slug)
            .pluck(:slug) || []
        end

        def relation_type_for_api(relation)
          case relation
          when CustomCheckSubject
            'custom'
          else
            relation.class.to_s
          end.downcase
        end
    end
  end
end
