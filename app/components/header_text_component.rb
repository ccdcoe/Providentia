# frozen_string_literal: true

class HeaderTextComponent < ViewComponent::Base
  attr_reader :text

  def initialize(text:)
    @text = text
  end

  private
    def breadcrumb_items
      [].tap do |items|
        if !%w[exercises versions clones docs].include?(controller_name) || action_name == 'new'
          items << [controller_class.to_icon, controller_action_text]
        end
      end
    end

    def controller_action_text
      case action_name
      when 'index'
        "List of #{controller_class.model_name.human.downcase.pluralize}"
      when 'show', 'edit', 'create'
        model_instance = controller.instance_variable_get("@#{controller_name.singularize}")
        model_instance.name
      when 'new'
        "New #{controller_class.model_name.human.downcase}"
      end
    end

    def controller_class
      controller_path.classify.constantize
    end
end
