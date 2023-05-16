# frozen_string_literal: true

class JobPosts::EmptyStateComponent < ApplicationComponent
  def template
    div(class: "text-center text-primary dark:text-white relative mb-12 block border border-grey dark:border-grey-lighter rounded-md px-4 py-4 sm:px-6 hover:opacity-75") do
      div(class: "mx-auto text-8xl") do
        i(class: "bx bxs-traffic-barrier")
      end
      h3(class: "mt-2 text-lg font-semibold") { "Oops! Nothing is here yet..." }
      p(class: "mt-1 text-lg font-light") { "Maybe you can try again later?" }
    end
  end
end
