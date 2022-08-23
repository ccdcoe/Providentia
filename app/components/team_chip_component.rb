# frozen_string_literal: true

class TeamChipComponent < ViewComponent::Base
  def initialize(team:, text: nil)
    @team = team
    @text = text
  end

  private
    def team_classes
      case @team.ui_color
      when 'yellow'
        "bg-#{@team.ui_color}-200 text-#{@team.ui_color}-800 dark:bg-#{@team.ui_color}-500 dark:text-#{@team.ui_color}-700"
      else
        "bg-#{@team.ui_color}-200 text-#{@team.ui_color}-800 dark:bg-#{@team.ui_color}-700 dark:text-#{@team.ui_color}-300"
      end
    end
end
