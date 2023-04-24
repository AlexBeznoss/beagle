# frozen_string_literal: true

class JobPosts::ListItemComponent < ApplicationComponent
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::TimeAgoInWords

  def initialize(job_post)
    @job_post = job_post
  end

  def template
    div(class: "relative mb-12 block flex flex-col md:flex-row items-center justify-between border border-grey dark:border-grey-lighter rounded-md px-4 py-4 sm:px-6 hover:opacity-75") do
      div(class: "flex flex-row w-full sm:w-max") do
        if logo_present?
          link_to @job_post.url, target: "_blank", rel: "noopener", **test_id("logo_link") do
            image_tag(
              logo_url,
              alt: @job_post.company,
              loading: "lazy",
              class: "h-12 w-12 mr-3 sm:h-16 sm:w-16 sm:mr-6 rounded-lg border border-grey border-2 dark:border-grey-lighter"
            )
          end
        end
        div(class: "flex flex-col justify-center align-center h-full max-w-[80%]") do
          link_to @job_post.url, target: "_blank", rel: "noopener" do
            h3(class: "font-body text-lg font-semibold text-primary dark:text-white") do
              plain @job_post.name
            end
            p(class: "font-body font-light text-primary dark:text-white") do
              plain @job_post.company
            end
          end
        end
      end
      div(class: "flex flex-row flex-wrap mt-1 items-end md:mt-0 md:flex-col") do
        link_to PROVIDER_URLS[@job_post.provider], target: "_blank", class: "m-1.5", rel: "noopener" do
          span class: "inline-flex items-center rounded-lg bg-pink-100 px-3 py-0.5 text-sm font-medium text-pink-800" do
            @job_post.provider_label
          end
        end
        if @job_post.location.present?
          span(class: "m-1.5 w-fit inline-flex items-center rounded-lg bg-purple-100 px-2.5 py-0.5 text-sm font-medium text-purple-800") do
            i(class: "bx bx-globe ml-0.5 mr-1.5 text-lg text-purple-600")
            whitespace
            plain @job_post.location
          end
        end
      end
      div(class: "absolute -bottom-5 left-1/2 -translate-x-1/2 w-max") do
        span(class: "m-1.5 w-fit inline-flex items-center rounded-lg bg-teal-100 px-2.5 py-0.5 text-sm font-medium text-teal-800") do
          i(class: "bx bx-calendar ml-0.5 mr-1.5 text-lg text-teal-600")
          plain "Posted"
          whitespace
          plain time_ago_in_words(@job_post.created_at)
          whitespace
          plain "ago"
        end
      end
    end
  end

  private

  def logo_present?
    @job_post.img.attached? || @job_post.img_url.present?
  end

  def logo_url
    return cfl_blob_url(@job_post.img) if @job_post.img.attached?

    @job_post.img_url
  end
end
