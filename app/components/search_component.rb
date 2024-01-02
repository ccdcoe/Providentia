# frozen_string_literal: true

class SearchComponent < ViewComponent::Base
  include Turbo::FramesHelper

  def initialize
  end

  private
    def query_classes
      %w(
        w-full border-0 focus:ring-transparent text-black
        placeholder-gray-400 dark:placeholder-gray-100
        appearance-none py-3 pl-10 pr-4
      )
    end

    def query_data
      {
        search_target: 'input',
        action: 'input->search#submit keydown.down->search#focusDown keydown.up->search#focusUp keydown.enter->search#followFocusLink'
      }
    end
end
