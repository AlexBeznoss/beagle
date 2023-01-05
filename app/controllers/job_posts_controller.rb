class JobPostsController < ApplicationController
  def index
    @pagy, @job_posts = pagy_countless(JobPost.order(posted_at: :desc, created_at: :desc))

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
