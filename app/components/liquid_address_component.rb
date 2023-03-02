# frozen_string_literal: true

class LiquidAddressComponent < LiquidTooltipSnippetComponent
  with_collection_parameter :object

  def initialize(object:, net_only: false)
    @object = object
    @net_only = net_only
  end

  def render?
    @object
  end

  private
    def template_text
      calc = UnsubstitutedAddress.new(@object)
      text = AddressValues.result_for(@object) || calc.send(:result)
      return text unless @net_only

      case text
      when /::/
        text.partition('::').slice(0, 2).join('')
      when /(:.*){7}/
        text.split(':').slice(0, calc.template_string.scan(':').size - 1).join(':')
      else
        text
      end
    end
end
