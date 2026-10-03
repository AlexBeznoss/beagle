# frozen_string_literal: true

class PaginationComponent < ApplicationComponent
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::LinkTo

  LINK_CLASS = "cursor-pointer border-2 border-primary px-3 py-1 font-body font-medium text-primary transition-colors hover:border-secondary hover:text-secondary dark:border-green-light dark:text-white dark:hover:border-secondary dark:hover:text-secondary"

  def initialize(pagy, extra_params = {})
    @pagy = pagy
    @extra_params = extra_params
  end

  def view_template
    return if !@pagy.previous && !@pagy.next

    div(class: "flex") do
      if @pagy.previous
        link_to pagination_path(page: @pagy.previous),
          class: LINK_CLASS,
          data: {turbo_frame: "_top"} do
            i(class: "bx bx-left-arrow-alt")
          end
      end
      span(class: class_names("border-2 border-secondary px-3 py-1 font-body font-medium text-secondary", "ml-3" => with_prev?)) { @pagy.page }

      if @pagy.next
        link_to pagination_path(page: @pagy.next),
          class: class_names("ml-3", LINK_CLASS),
          data: {turbo_frame: "_top"} do
            i(class: "bx bx-right-arrow-alt")
          end
      end
    end
  end

  private

  def with_prev?
    @pagy.previous
  end

  def pagination_path(page:)
    other_params = {}
    other_params[:search] = {q: @extra_params[:search]} if @extra_params[:search]

    url_for(page:, **other_params)
  end
end
