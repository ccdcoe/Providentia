# frozen_string_literal: true

require 'redcarpet'
require 'rouge'
require 'rouge/plugins/redcarpet'

class CustomRender < Redcarpet::Render::HTML
  include Rouge::Plugins::Redcarpet
end

class MarkdownTemplateHandler
  def erb
    @erb ||= ActionView::Template.registered_template_handler(:erb)
  end

  def call(template, source)
    compiled_source = erb.call(template, source)
    "Redcarpet::Markdown.new(CustomRender,
      no_intra_emphasis:            true,
      fenced_code_blocks:           true,
      space_after_headers:          true,
      smartypants:                  true,
      disable_indented_code_blocks: true,
      prettify:                     true,
      tables:                       true,
      with_toc_data:                true,
      autolink:                     true
    ).render(begin;#{compiled_source};end.to_s).html_safe"
  end
end

ActionView::Template.register_template_handler(:md, MarkdownTemplateHandler.new)
