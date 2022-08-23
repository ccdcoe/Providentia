# frozen_string_literal: true

class LiquidTooltipSnippetComponent < ViewComponent::Base
  def initialize(object:)
    @object = object
  end

  def call
    LiquidReplacer.new(template_text).iterate do |variable_node|
      content_tag(
        :strong,
        "[ #{variable_node.name.name} ]",
        { data: { controller: 'tippy', tooltip: tooltip_for(variable_node) } }
      )
    end.html_safe
  end

  private
    def template_text
      raise 'Implement me!'
    end

    def exercise
      @object.exercise
    end

    def tooltip_for(node)
      "#{node.name.name}: " +
      case node.name.name
      when 'team_nr'
        exercise.all_blue_teams.values_at(0, -1).map do |team|
          node.render(Liquid::Context.new('team_nr' => team.to_s))
        end.join ' - '
      when 'seq'
        if @object.is_a?(VirtualMachine)
          "01 - #{@object.custom_instance_count.to_s.rjust(2, '0')}"
        end
      end.to_s
    end
end
