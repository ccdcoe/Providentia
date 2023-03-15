# frozen_string_literal: true

class LiquidAddressComponent < LiquidTooltipSnippetComponent
  with_collection_parameter :object

  def render?
    @object
  end

  private
    def template_text
      calc = UnsubstitutedAddress.new(@object)
      text = AddressValues.result_for(@object) || calc.send(:result)

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
