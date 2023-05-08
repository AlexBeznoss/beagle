# frozen_string_literal: true

class NavigationComponent < ApplicationComponent
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ImageTag

  def initialize(with_logo)
    @with_logo = with_logo
  end

  def template
    div(data: {controller: "navigation theme"}) do
      div(class: "container mx-auto") do
        div(class: tokens("flex items-center justify-end py-3 lg:py-6", with_logo?: "justify-between")) do
          render_logo if with_logo?

          div(class: "flex items-center lg:hidden") do
            div(data: {controller: "profile"}, class: "relative mr-3 z-30 block px-2")
            i(
              class: "bx mr-3 cursor-pointer text-3xl text-primary dark:text-white",
              data_theme_target: "icon",
              data_action: "click->theme#switchTheme"
            )
            i(
              class: "bx bx-menu-alt-right text-3xl fill-current text-primary dark:text-white",
              data_action: "click->navigation#toggle"
            )
          end

          div(class: "hidden lg:block") do
            ul(class: "flex items-center justify-end") do
              if Current.verified?
                li(class: "group relative mr-6 mb-1") do
                  div(class: "absolute left-0 bottom-0 z-20 h-0 w-full opacity-75 transition-all group-hover:h-2 group-hover:bg-yellow")
                  link_to(
                    "Bookmarks",
                    bookmarks_path,
                    class: "relative z-30 block px-2 font-body text-lg font-medium text-primary transition-colors group-hover:text-green dark:text-white dark:group-hover:text-secondary"
                  )
                end
                li(class: "group relative mr-6 mb-1") do
                  div(data: {controller: "profile"}, class: "relative z-30 block px-2")
                end
              else
                li(class: "group relative mr-6 mb-1") do
                  div(class: "absolute left-0 bottom-0 z-20 h-0 w-full opacity-75 transition-all group-hover:h-2 group-hover:bg-yellow")
                  button(data: {controller: "login", action: "click->login#trigger"}, class: "relative z-30 block px-2 font-body text-lg font-medium text-primary transition-colors group-hover:text-green dark:text-white dark:group-hover:text-secondary") { "Sign in" }
                end
              end
              li do
                i(
                  class: "bx cursor-pointer text-3xl text-primary dark:text-white",
                  data_theme_target: "icon",
                  data_action: "click->theme#switchTheme"
                )
              end
            end
          end
        end
      end

      div(data_navigation_target: "mobile", class: "pointer-events-none fixed inset-0 z-50 flex bg-black bg-opacity-80 opacity-0 transition-opacity lg:hidden") do
        div(class: "ml-auto w-2/3 bg-green p-4 md:w-1/3") do
          i(
            data_action: "click->navigation#toggle",
            class: "bx bx-x absolute top-0 right-0 mt-4 mr-4 text-4xl text-white"
          )
          ul(class: "mt-8 flex flex-col") do
            if Current.verified?
              li do
                link_to(
                  "Bookmarks",
                  bookmarks_path,
                  class: "mb-3 block px-2 font-body text-lg font-medium text-white"
                )
              end
            else
              li do
                button(data: {controller: "login", action: "click->login#trigger"}, class: "mb-3 block px-2 font-body text-lg font-medium text-white") { "Sign in" }
              end
            end
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
      p(class: "font-body text-2xl font-bold text-primary dark:text-white") do
        "BeagleJobs"
      end
    end
  end

  def with_logo?
    @with_logo
  end
end
