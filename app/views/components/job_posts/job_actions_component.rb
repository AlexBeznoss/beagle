# frozen_string_literal: true

class JobPosts::JobActionsComponent < ApplicationComponent
  include Phlex::Rails::Helpers::ButtonTo
  include Phlex::Rails::Helpers::Routes

  def initialize(job_post)
    @job_post = job_post
  end

  def template
    div(class: "flex flex-row absolute right-0 -top-2") do
      if @job_post.bookmark_id.present?
        remove_button
      else
        add_button
      end
    end
  end

  private

  def remove_button
    button_to job_post_bookmark_path(@job_post, @job_post.bookmark_id), method: :delete do
      i(
        class: "bx bxs-bookmark-alt-minus text-3xl text-primary bg-white dark:text-white dark:bg-primary"
      )
    end
  end

  def add_button
    button_to job_post_bookmarks_path(@job_post), method: :post do
      i(
        class: "bx bxs-bookmark-alt-plus text-3xl text-primary bg-white dark:text-white dark:bg-primary"
      )
    end
  end
end
