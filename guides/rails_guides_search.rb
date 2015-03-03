pwd = File.dirname(__FILE__)
$:.unshift pwd

# This is a predicate useful for the doc:guides task of applications.
def bundler?
  # Note that rake sets the cwd to the one that contains the Rakefile
  # being executed.
  File.exist?('Gemfile')
end

begin
  # Guides generation in the Rails repo.
  as_lib = File.join(pwd, "../activesupport/lib")
  ap_lib = File.join(pwd, "../actionpack/lib")

  $:.unshift as_lib if File.directory?(as_lib)
  $:.unshift ap_lib if File.directory?(ap_lib)
rescue LoadError
  # Guides generation from gems.
  gem "actionpack", '>= 3.0'
end

begin
  require 'redcarpet'
rescue LoadError
  # This can happen if doc:guides is executed in an application.
  $stderr.puts('Generating guides requires Redcarpet 2.1.1+.')
  $stderr.puts(<<ERROR) if bundler?
Please add

  gem 'redcarpet', '~> 2.1.1'

to the Gemfile, run

  bundle install

and try again.
ERROR
  exit 1
end

begin
  require 'nokogiri'
rescue LoadError
  # This can happen if doc:guides is executed in an application.
  $stderr.puts('Generating guides requires Nokogiri.')
  $stderr.puts(<<ERROR) if bundler?
Please add

  gem 'nokogiri'

to the Gemfile, run

  bundle install

and try again.
ERROR
  exit 1
end

require 'rails_guides/markdown'
require "rails_guides/generator"
require "rails_guides/search_generator"
require "search/guide_search"
require "pry"

texts_hashs = RailsGuides::SearchGenerator.new.generate

db = GuideSearch::Database.new
db.open('./tmp')
entries = Groonga["Entries"]
bigram = Groonga["Bigram"]

# entries = Groonga["Entries"]
# entries.add("String#sub",
#             name: "sub",
#             summary: "置換",
#             description: "1つ置換")
# entries.add("String#gsub",
#             name: "gsub",
#             summary: "置換",
#             description: "全部置換")

texts_hashs.each do |hash|
  html_name = hash[:html_name]
  hash[:text_groups].each do |text_group|
    entries.add("#{html_name}##{text_group.header_text}", description: text_group.description)
  end
end
binding.pry
entries.select {|record| record.description =~ "Record"}
