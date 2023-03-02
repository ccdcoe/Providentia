# frozen_string_literal: true

class LiquidDomainComponent < LiquidTooltipSnippetComponent
  private
    def template_text
      HostnameGenerator.result_for(@object.host_spec).domain
    end
end
