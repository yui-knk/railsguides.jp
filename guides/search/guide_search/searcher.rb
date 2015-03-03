require "groonga"

module GuideSearch
  class Searcher
    def initialize(database, base_dir=nil, options={})
      @database = database
      @base_dir = base_dir
      @options = options
    end

    def search(word)
      _search(word).sort([{key: "_score", order: "descending"}])
    end

    private
    def _search(word)
      @database.entries.select {|record| record.description =~ word}
    end
  end
end
