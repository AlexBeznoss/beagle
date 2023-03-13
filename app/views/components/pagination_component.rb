# frozen_string_literal: true

class PaginationComponent < ApplicationComponent
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::LinkTo
  LINK_CLASS = "cursor-pointer border-2 border-primary px-3 py-1 font-body font-medium text-primary transition-colors hover:border-secondary hover:text-secondary dark:border-green-light dark:text-white dark:hover:border-secondary dark:hover:text-secondary"

  def initialize(pagy, other_params = {})
    @pagy = pagy
    @other_params = other_params
  end

  def template
    return if !@pagy.prev && !@pagy.next

    div(class: "flex") do
      if @pagy.prev
        link_to pagination_path(page: @pagy.prev),
          class: LINK_CLASS,
          data: {turbo_frame: "_top"} do
            i(class: "bx bx-left-arrow-alt")
          end
      end
      span(class: tokens("border-2 border-secondary px-3 py-1 font-body font-medium text-secondary", with_prev?: "ml-3")) { @pagy.page }

      if @pagy.next
        link_to pagination_path(page: @pagy.next),
          class: tokens("ml-3", LINK_CLASS),
          data: {turbo_frame: "_top"} do
            i(class: "bx bx-right-arrow-alt")
          end
      end
    end
  end

  private

  def with_prev?
    @pagy.prev
  end

  def pagination_path(page:)
    url_for(page:, **@other_params.select { |_, v| v.present? })
  end
end
