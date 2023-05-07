# frozen_string_literal: true

class NavigationComponent < ApplicationComponent
  def template
    div(data: {controller: "navigation theme"}) do
      div(class: "container mx-auto") do
        div(class: "flex items-center justify-end py-3 lg:py-6") do
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
        end

        div(class: "hidden lg:block") do
          ul(class: "flex items-center justify-end") do
            if Current.verified?
              li(class: "group relative mr-6 mb-1") do
                div(class: "absolute left-0 bottom-0 z-20 h-0 w-full opacity-75 transition-all group-hover:h-2 group-hover:bg-yellow")
                a(href: "/", class: "relative z-30 block px-2 font-body text-lg font-medium text-primary transition-colors group-hover:text-green dark:text-white dark:group-hover:text-secondary") { "Bookmarks" }
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

      div(data_navigation_target: "mobile", class: "pointer-events-none fixed inset-0 z-50 flex bg-black bg-opacity-80 opacity-0 transition-opacity lg:hidden") do
        div(class: "ml-auto w-2/3 bg-green p-4 md:w-1/3") do
          i(
            data_action: "click->navigation#toggle",
            class: "bx bx-x absolute top-0 right-0 mt-4 mr-4 text-4xl text-white"
          )
          ul(class: "mt-8 flex flex-col") do
            if Current.verified?
              li do
                a(href: "/", class: "mb-3 block px-2 font-body text-lg font-medium text-white") { "Bookmarks" }
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
end
