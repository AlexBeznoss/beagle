# frozen_string_literal: true

class JobPosts::IndexView < ApplicationView
  include Phlex::Rails::Helpers::TextField
  include Phlex::Rails::Helpers::TurboFrameTag

  def initialize(job_posts:, pagy:, search_query:)
    @job_posts = job_posts
    @pagy = pagy
    @search_query = search_query
  end

  def view_template
    render JobPosts::HeaderComponent.new

    div class: "py-6 pb-16 lg:pb-20 lg:py-12 min-h-[60vh]" do
      render JobPosts::SearchComponent.new(@search_query)
      turbo_frame_tag "job_posts" do
        render JobPosts::EmptyStateComponent.new if @job_posts.empty?

        @job_posts.each do |jp|
          render JobPosts::ListItemComponent.new(jp) do |item|
            item.actions do
              JobPosts::ToggleBookmarkComponent.new(
                jp,
                create_path: ->(jp) { job_post_bookmarks_path(jp) },
                destroy_path: ->(jp) { job_post_bookmark_path(jp, jp.bookmark_id) }
              )
            end
          end
        end
      end
      turbo_frame_tag "job_posts_pagination" do
        render PaginationComponent.new(
          @pagy,
          search: @search_query
        )
      end
    end
  end
end
