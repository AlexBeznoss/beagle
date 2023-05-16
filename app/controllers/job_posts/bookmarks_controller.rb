class JobPosts::BookmarksController < ApplicationController
  before_action :require_signin!
  before_action :find_job_post

  def create
    bookmark = @job_post.bookmarks.find_or_create_by!(user_id: Current.user_id)
    @job_post.bookmark_id = bookmark.id

    respond_to do |f|
      f.turbo_stream
      f.html { redirect_to current_path, notice: t("bookmarks.created") }
    end
  end

  def destroy
    @job_post.bookmarks.find(params[:id]).destroy!
    @job_post.bookmark_id = nil

    respond_to do |f|
      f.turbo_stream
      f.html { redirect_to current_path, notice: t("bookmarks.destroy") }
    end
  end

  private

  def find_job_post
    @job_post = JobPost.find(params[:job_post_id])
  end
end
