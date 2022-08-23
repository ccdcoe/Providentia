# frozen_string_literal: true

class LiquidFQDNComponent < LiquidTooltipSnippetComponent
  private
    def template_text
      @object.connection_nic&.fqdn
    end
end
