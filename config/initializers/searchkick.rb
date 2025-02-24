# config/initializers/searchkick.rb
Searchkick.client = OpenSearch::Client.new(hosts: ["http://localhost:9200"])
