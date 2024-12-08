# frozen_string_literal: true

class Bookmarks::IndexView < ApplicationView
  include Phlex::Rails::Helpers::TextField
  include Phlex::Rails::Helpers::TurboFrameTag

  def initialize(job_posts:, pagy:)
    @job_posts = job_posts
    @pagy = pagy
  end

  def view_template
    div(class: "border-b border-grey-lighter mt-6")
    div class: "py-6 pb-16 lg:pb-20 lg:py-12 min-h-[60vh]" do
      turbo_frame_tag "job_posts" do
        render JobPosts::EmptyStateComponent.new if @job_posts.empty?

        @job_posts.each do |jp|
          render JobPosts::ListItemComponent.new(jp) do |item|
            item.actions do
              JobPosts::ToggleBookmarkComponent.new(
                jp,
                destroy_path: ->(jp) { bookmark_path(jp.bookmark_id) }
              )
            end
          end
        end
      end
      turbo_frame_tag "job_posts_pagination" do
        render PaginationComponent.new(@pagy)
      end
    end
  end
end
