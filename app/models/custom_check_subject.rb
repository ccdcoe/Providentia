# frozen_string_literal: true

class CustomCheckSubject < ApplicationRecord
  def name
    "#{base_class.constantize.model_name.human}: #{meaning}"
  end

  def api_name
    meaning.parameterize
  end

  def type_for_api
    'custom'
  end

  def safe_class
    if %w(CustomizationSpec Network).include?(base_class)
      base_class.to_s.constantize
    end
  end
end
