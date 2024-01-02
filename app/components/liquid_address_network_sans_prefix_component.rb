# frozen_string_literal: true

class LiquidAddressNetworkSansPrefixComponent < LiquidTooltipSnippetComponent
  private
    def template_text
      @object.ip_family_network_template.gsub(/\/\d+\z/, '')
    end
end
