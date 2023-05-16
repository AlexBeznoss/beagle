# frozen_string_literal: true

class JobPosts::ToggleBookmarkComponent < ApplicationComponent
  include Phlex::Rails::Helpers::ButtonTo
  include Phlex::Rails::Helpers::TurboFrameTag

  def initialize(job_post, create_path: nil, destroy_path: nil)
    @job_post = job_post
    @create_path = create_path
    @destroy_path = destroy_path
  end

  def template
    turbo_frame_tag("bookmark_toggle_#{@job_post.id}") do
      button_to bookmark_action_path, bookmark_action_params do
        i(class: "bx text-3xl text-primary bg-white dark:text-white dark:bg-primary #{bookmark_action_icon}")
      end
    end
  end

  private

  def bookmark_action_path
    return @destroy_path.call(@job_post) if has_bookmark?

    @create_path.call(@job_post)
  end

  def bookmark_action_params
    test_id("Bookmarks/#{@job_post.id}/#{bookmark_action_method}")
      .merge(method: bookmark_action_method)
  end

  def bookmark_action_method
    has_bookmark? ? :delete : :post
  end

  def bookmark_action_icon
    has_bookmark? ? "bxs-bookmark-alt-minus" : "bxs-bookmark-alt-plus"
  end

  def has_bookmark?
    @job_post.bookmark_id.present?
  end
end
