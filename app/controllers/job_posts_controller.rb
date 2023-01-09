class JobPostsController < ApplicationController
  def index
    @pagy, @job_posts = pagy_countless(JobPost.for_index)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def search
    collection = [JobPost.includes(img_attachment: :blob), params.dig(:search, :q), {}]

    @pagy, @job_posts = pagy_meilisearch(collection)

    render :index
  end
end
