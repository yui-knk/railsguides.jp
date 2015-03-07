require 'rails_guides/markdown/search_renderer'

module RailsGuides
  class SearchMarkdown < Markdown
    private
      def engine
        @engine ||= Redcarpet::Markdown.new(Markdown::SearchRenderer, {
          no_intra_emphasis: true,
          fenced_code_blocks: true,
          autolink: true,
          strikethrough: true,
          superscript: true,
          tables: true
        })
      end
  end
end
