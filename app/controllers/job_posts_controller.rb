class JobPostsController < ApplicationController
  def index
    pagy, job_posts = pagy_countless(JobPost.for_index)

    render JobPosts::IndexView.new(
      job_posts:,
      pagy:,
      search_query: params.dig(:search, :q)
    )
  end

  def search
    collection = [JobPost.includes(img_attachment: :blob), params.dig(:search, :q), {}]

    pagy, job_posts = pagy_meilisearch(collection)

    render JobPosts::IndexView.new(
      job_posts:,
      pagy:,
      search_query: params.dig(:search, :q)
    )
  end
end
