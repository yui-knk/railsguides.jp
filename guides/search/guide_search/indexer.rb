module GuideSearch
  class Indexer
    # expect already database to be opened
    def initialize(database, guide_database)
      @database = database
      @guide_database = guide_database
    end

    def index
      # @method_database.docs.each do |doc|
      #   index_document(doc)
      #   doc.unload
      # end
      @guide_database.each do |hash|
        html_name = hash[:html_name]
        hash[:text_groups].each do |text_group|
          @database.entries.add("#{html_name}##{dom_id_text(text_group.header_text)}", description: text_group.description)
        end
      end
    end

    private
    # RailsGuides::Markdown
    def dom_id_text(text)
      text.downcase.strip.gsub(/\s+/, '-')
    end
  end
end
