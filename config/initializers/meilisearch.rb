MeiliSearch::Rails.configuration = {
  meilisearch_host: ENV.fetch("MEILISEARCH_URL"),
  meilisearch_api_key: ENV.fetch("MEILISEARCH_MASTER_KEY")
}
