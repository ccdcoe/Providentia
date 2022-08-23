# frozen_string_literal: true

class ModalComponent < ViewComponent::Base
  renders_one :body

  def initialize(header:, full_screen: false)
    @header = header
    @full_screen = full_screen
  end

  private
    def size_classes
      if @full_screen
        'h-screen w-full'
      else
        'max-h-screen w-full max-w-5xl'
      end
    end

    def content_classes
      if @full_screen
        'h-full flex-grow'
      end
    end
end
