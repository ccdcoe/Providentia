# frozen_string_literal: true

class LiquidPoolNetworkComponent < LiquidTooltipSnippetComponent
  private
    def template_text
      @object.network_address
    end
end
