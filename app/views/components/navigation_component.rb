# frozen_string_literal: true

class NavigationComponent < ApplicationComponent
  def template
    div(class: "container mx-auto") do
      div(class: "flex items-center justify-end py-3 lg:py-6") do
        div(class: "block") do
          ul(class: "flex items-center") do
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
  end
end
