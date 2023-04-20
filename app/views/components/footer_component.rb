# frozen_string_literal: true

class FooterComponent < ApplicationComponent
  def template
    div(class: "container mx-auto") do
      div(class: "flex flex-col items-center justify-between border-t border-grey-lighter py-10 sm:flex-row sm:py-12") do
        div(class: "mr-auto flex flex-col") do
          div(class: "pt-5 font-body font-light text-primary dark:text-white sm:pt-0") do
            whitespace
            plain "© 2023 BeagleJobs. All rights reserved."
          end
          div(class: "pt-5 font-body font-light text-primary dark:text-white sm:pt-0") do
            whitespace
            plain "Logo image based on an illustration from"
            whitespace
            a(
              href:
              "https://vectorcharacters.net/animal-vector-characters/dogs",
              class: "hover:opacity-75",
              target: "_blank"
            ) { "VectorCharacters" }
          end
          div(class: "pt-5 font-body font-light text-primary dark:text-white sm:pt-0") do
            whitespace
            plain "Design based on"
            whitespace
            a(
              href: "https://redpixelthemes.gumroad.com/l/twm-atlas",
              class: "hover:opacity-75",
              target: "_blank"
            ) { "Atlas template" }
          end
        end
      end
    end
  end
end
