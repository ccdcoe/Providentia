# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  nilify_blanks types: [:text, :string]

  def preload(*args)
    preloader = ActiveRecord::Associations::Preloader.new
    preloader.preload(self, *args)
  end
end
