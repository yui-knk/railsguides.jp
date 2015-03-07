require 'rails_guides/search_generator'
require 'rails_guides/search_markdown'

module RailsGuides
  class SearchGenerator < Generator
    GUIDES_RE = /\.md\z/

    def initialize(output=nil)
      set_flags_from_environment

      initialize_dirs(output)
    end

    def generate
      texts_hash = generate_guides
    end

    private

    def generate_guides
      guides_to_generate.map do |guide|
        next if guide =~ /\.erb\z/
        output_file = output_file_for(guide)
        generate_guide(guide, output_file) #if generate?(guide, output_file)
      end.compact
    end

    def generate_guide(guide, output_file)
      # output_path = output_path_for(output_file)
      puts "Generating #{guide} as #{output_file}"
      layout = kindle? ? 'kindle/layout' : 'layout'

      view = ActionView::Base.new(source_dir, :edge => @edge, :version => @version, :mobi => "kindle/#{mobi}")
      view.extend(Helpers)

      # if guide =~ /\.(\w+)\.erb$/
        # Generate the special pages like the home.
        # Passing a template handler in the template name is deprecated. So pass the file name without the extension.
        # result = view.render(:layout => layout, :formats => [$1], :file => $`)
      # else
        body = File.read(File.join(source_dir, guide))
        body = body << references_md(guide) if references?(guide)
        markdown = RailsGuides::SearchMarkdown.new(view, layout)
        result = markdown.render(body)

        warn_about_broken_links(result) if @warnings
      # end

      html_name = guide.sub(".md", ".html")
      { html_name: html_name, text_groups: markdown.send(:engine).renderer.text_groups }
    end
  end
end
