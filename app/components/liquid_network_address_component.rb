# frozen_string_literal: true

class LiquidNetworkAddressComponent < LiquidTooltipSnippetComponent
  with_collection_parameter :object

  def render?
    @object
  end

  private
    def template_text
      @object.network_address.gsub(/\/\d+\z/, '')
    end
end
