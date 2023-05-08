# frozen_string_literal: true

class JobPosts::JobActionsComponent < ApplicationComponent
  include Phlex::Rails::Helpers::ButtonTo
  include Phlex::Rails::Helpers::Routes

  def initialize(job_post, namespace:)
    @job_post = job_post
    @namespace = namespace
  end

  def template
    div(class: "flex flex-row absolute right-0 -top-2") do
      bookmark_button
    end
  end

  private

  def bookmark_button
    button_to bookmark_action_path, method: bookmark_action_method do
      i(class: "bx text-3xl text-primary bg-white dark:text-white dark:bg-primary #{bookmark_action_icon}")
    end
  end

  def bookmark_action_path
    case [@namespace, has_bookmark?]
    when [:job_posts, true]
      job_post_bookmark_path(@job_post, @job_post.bookmark_id)
    when [:job_posts, false]
      job_post_bookmarks_path(@job_post)
    when [:bookmarks, true]
      bookmark_path(@job_post.bookmark_id)
    else
      raise "Namespace #{@namespace} when has_bookmark? is #{has_bookmark?} is not supported."
    end
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
