# frozen_string_literal: true

class JobPosts::HeaderComponent < ApplicationComponent
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::LinkTo

  def view_template
    div(class: "border-b border-grey-lighter py-6 flex justify-between lg:py-12") do
      div(class: "hidden sm:block") do
        image_tag "logo.svg", alt: "logo", class: "w-96"
      end
      div(class: "ml-3") do
        h1(class: "pt-3 font-body text-4xl font-semibold text-primary dark:text-white md:text-5xl lg:text-6xl") do
          a(href: "/") { "BeagleJobs" }
        end
        p(class: "pt-3 font-body text-xl font-light text-primary dark:text-white") do
          plain "Accurate list of Remote Ruby jobs from"
          whitespace
          link_to "GoRails Jobs", PROVIDER_URLS["gorails"], target: "_blank", rel: "noopener"
          plain ","
          whitespace
          link_to "RemoteOK", PROVIDER_URLS["remoteok"], target: "_blank", rel: "noopener"
          plain ","
          whitespace
          link_to "RubyOnRemote", PROVIDER_URLS["rubyonremote"], target: "_blank", rel: "noopener"
          plain ","
          whitespace
          link_to "WeWorkRemotely", PROVIDER_URLS["weworkremotely"], target: "_blank", rel: "noopener"
          whitespace
          plain "and"
          whitespace
          link_to "StartupJobs", PROVIDER_URLS["startupjobs"], target: "_blank", rel: "noopener"
          plain "."
        end
      end
    end
  end
end
