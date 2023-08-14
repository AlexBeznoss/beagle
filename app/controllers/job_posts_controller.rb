class JobPostsController < ApplicationController
  layout -> { ApplicationLayout.with(logo: false) unless turbo_frame_request? }

  def index
    pagy, job_posts = pagy_countless(jobs_query)

    render JobPosts::IndexView.new(
      job_posts:,
      pagy:,
      search_query: params.dig(:search, :q)
    )
  end

  def search
    collection = jobs_query.search(params.dig(:search, :q))

    pagy, job_posts = pagy_countless(collection)

    render JobPosts::IndexView.new(
      job_posts:,
      pagy:,
      search_query: params.dig(:search, :q)
    )
  end

  private

  def jobs_query
    query = JobPost.for_index
    query = query.with_bookmark_id(Current.user_id) if Current.verified?
    query
  end
end
