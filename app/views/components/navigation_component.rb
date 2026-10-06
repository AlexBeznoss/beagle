# frozen_string_literal: true

class NavigationComponent < ApplicationComponent
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ImageTag

  def initialize(with_logo)
    @with_logo = with_logo
  end

  def view_template
    div(data: {controller: "theme"}) do
      div(class: "container mx-auto") do
        div(class: class_names("flex items-center justify-end py-3 lg:py-6", "justify-between" => @with_logo)) do
          render_logo if @with_logo
          button(
            type: "button",
            aria_label: "Switch theme",
            title: "Switch theme",
            data_action: "click->theme#switchTheme",
            class: "cursor-pointer p-2 text-3xl text-primary dark:text-white"
          ) do
            i(class: "bx", data_theme_target: "icon", aria_hidden: "true")
          end
        end
      end
    end
  end

  private

  def render_logo
    link_to(root_path, class: "flex items-center") do
      span(class: "mr-2") do
        image_tag "logo.svg", class: "hidden lg:block h-10", alt: "BeagleJobs Logo"
      end
      p(class: "font-body text-2xl font-bold text-primary dark:text-white") { "BeagleJobs" }
    end
  end
end
