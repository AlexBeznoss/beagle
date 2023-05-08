class JobPostsController < ApplicationController
  def index
    pagy, job_posts = pagy_countless(jobs_query)

    render JobPosts::IndexView.new(
      job_posts:,
      pagy:,
      search_query: params.dig(:search, :q)
    )
  end

  def search
    collection = [jobs_query, params.dig(:search, :q), {}]

    pagy, job_posts = pagy_meilisearch(collection)

    render JobPosts::IndexView.new(
      job_posts:,
      pagy:,
      search_query: params.dig(:search, :q)
    )
  end

  private

  def jobs_query
    query = JobPost.for_index
    query = query.with_bookmark(Current.user_id) if Current.verified?
    query
  end
end
