class BookmarksController < ApplicationController
  before_action :require_signin!

  def index
    pagy, job_posts = pagy_countless(jobs_query)

    render Bookmarks::IndexView.new(job_posts:, pagy:)
  end

  def destroy
    bookmark = Bookmark.find_by!(user_id: Current.user_id, id: params[:id])
    @job_post = bookmark.job_post
    bookmark.destroy!

    respond_to do |f|
      f.turbo_stream
      f.html { redirect_to bookmarks_path, notice: t("bookmarks.destroy") }
    end
  end

  private

  def jobs_query
    JobPost.for_bookmarks_index(Current.user_id)
  end
end
