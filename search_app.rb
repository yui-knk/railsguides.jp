require "sinatra"
require_relative "guides/search/guide_search"

get '/' do
  'Hello world!'
end

get '/search/:name' do
  db = GuideSearch::Database.new
  db_base_dir = File.expand_path('../guides/tmp', __FILE__)
  db.open(db_base_dir)
  searcher = GuideSearch::Searcher.new(db)

  searcher.search(params[:name]).map do |record|
    [record.score, record._key]
  end.to_s
end
