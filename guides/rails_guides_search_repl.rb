pwd = File.dirname(__FILE__)
$:.unshift pwd

require "search/guide_search"
require "pry"

db = GuideSearch::Database.new
db_base_dir = File.expand_path('../tmp', __FILE__)
db.open(db_base_dir)
searcher = GuideSearch::Searcher.new(db)

binding.pry
searcher.search("PostgreSQL").map do |record|
  [record.score, record._key]
end
