MeiliSearch::Rails.configuration = {}.tap do |params|
  if Rails.env.production?
    params[:meilisearch_url] = Rails.application.credentials.dig(:meilisearch, :url)
    params[:meilisearch_api_key] = Rails.application.credentials.dig(:meilisearch, :api_key)
  else
    params[:meilisearch_url] = "http://localhost:7700"
  end
end
