require_relative "renderer"

module RailsGuides
  class Markdown
    class TextGroup
      attr_reader :header_text

      def initialize(header_text, header_level)
        @header_text = header_text # id
        @header_level = header_level
        @block_codes = []
        @paragraphs = []
      end

      def block_codes_to_s
        @block_codes.inject("") {|str, block_code| str << block_code[:code] << "\n" }
      end

      def paragraphs_to_s
        @paragraphs.inject("") {|str, paragraph| str << paragraph[:text] << "\n" }
      end

      def description
        paragraphs_to_s << "\n" << block_codes_to_s
      end

      def add_block_code(code, language)
        @block_codes << { code: code, language: language }
      end

      def add_paragraph(text)
        @paragraphs << { text: text }
      end
    end

    class SearchRenderer < Renderer
      attr_reader :text_groups

      def initialize(options={})
        @text_groups = []
        super
      end

      def block_code(code, language)
        @text_groups.last.add_block_code(code, language)
        super
      end

      def header(text, header_level)
        @text_groups << TextGroup.new(text, header_level)
        super
      end

      def paragraph(text)
        @text_groups.last.add_paragraph(text)
        super
      end
    end
  end
end
