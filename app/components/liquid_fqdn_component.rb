# frozen_string_literal: true

class LiquidFQDNComponent < LiquidTooltipSnippetComponent
  private
    def template_text
      HostnameGenerator.result_for(@object.host_spec).fqdn
    end
end
