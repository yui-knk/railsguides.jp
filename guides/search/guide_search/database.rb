require "groonga"

module GuideSearch
  class Database
    def initialize
      @context = nil
      @database = nil
    end

    def open(base_path)
      reset_context
      path = File.join(base_path, "guide.db")
      if File.exist?(path)
        @database = @context.open_database(path)
        populate_schema
      else
        FileUtils.mkdir_p(base_path)
        populate(path)
      end
      if block_given?
        begin
          yield(self)
        ensure
          close unless closed?
        end
      end
    end

    def reopen
      base_path = File.dirname(@database.path)
      # encoding = @database.encoding
      close
      # open(base_path, encoding)
      open(base_path)
    end

    def reset_context
      @context.close if @context
      @context = Groonga::Context.new(encoding: :utf8)
    end

    def populate(path)
      @database = @context.create_database(path: path) #(path: "/tmp/bookmark.db")
      populate_schema
    end

    def purge
      path = @database.path
      encoding = @database.encoding
      @database.remove
      directory = File.dirname(path)
      FileUtils.rm_rf(directory)
      FileUtils.mkdir_p(directory)
      reset_context
      populate(path)
    end

    def close
      @database.close
      @database = nil
      @context.close
      @context = nil
    end

    def closed?
      @database.nil? or @database.closed?
    end

    def entries
      @context["Entries"]
    end

    def populate_schema
      Groonga::Schema.define(context: @context) do |schema|
        schema.create_table("Entries",
                            :type => :hash,
                            :key_type => "ShortText") do |table|
          # table.reference("name", "Names")
          # table.reference("local_name", "LocalNames")

          # table.text("block_code")
          # table.text("paragraph")
          table.text("description")

          # table.reference("type", "Types")
          # table.reference("class", "Classes")
          # table.reference("normalized_class", "NormalizedClasses")
          # table.reference("module", "Modules")
          # table.reference("normalized_module", "NormalizedModules")
          # table.reference("object", "Objects")
          # table.reference("normalized_object", "NormalizedObjects")
          # table.reference("library", "Libraries")
          # table.reference("version", "Versions")
          # table.reference("visibility", "Visibilities")
          # table.reference("related_names", "Names", :type => :vector)
          # table.time("last_modified")
        end

        schema.create_table("Bigram",
                            :type => :patricia_trie,
                            :key_type => "ShortText",
                            :default_tokenizer => "TokenBigram",
                            :key_normalize => true) do |table|
          # table.index("Entries.document")
          # table.index("Entries.summary")
          table.index("Entries.description")
        end
      end
    end

  end
end
