# frozen_string_literal: true

class ParameterizedTagParser < ActsAsTaggableOn::GenericParser
  def parse
    ActsAsTaggableOn::TagList.new.tap do |tag_list|
      tag_list.add @tag_list
        .split(',')
        .map { |part| part.to_url.tr('-', '_') }
    end
  end
end
