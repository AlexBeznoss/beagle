# frozen_string_literal: true

class ApplicationLayout < ApplicationView
  include Phlex::Rails::Layout
  include Phlex::Rails::Helpers::AssetPath

  def template(&block)
    doctype

    html class: "dark" do
      head do
        title { "BeagleJobs - Accurate list of Remote Ruby Jobs" }
        meta name: "viewport", content: "width=device-width,initial-scale=1"
        csp_meta_tag
        csrf_meta_tags
        stylesheet_link_tag "tailwind", "inter-font", data_turbo_track: "reload"
        stylesheet_link_tag "application", data_turbo_track: "reload"
        javascript_importmap_tags
        script src: "https://plausible.io/js/script.js", data_domain: "beaglejobs.com", defer: true
        link(
          rel: "apple-touch-icon",
          sizes: "180x180",
          href: (asset_path "favicon/apple-touch-icon.png")
        )
        link(
          rel: "icon",
          type: "image/png",
          sizes: "32x32",
          href: (asset_path "favicon/favicon-32x32.png")
        )
        link(
          rel: "icon",
          type: "image/png",
          sizes: "16x16",
          href: (asset_path "favicon/favicon-16x16.png")
        )
        link(
          rel: "mask-icon",
          href: (asset_path "favicon/safari-pinned-tab.svg"),
          color: "#5bbad5"
        )
        link(rel: "shortcut icon", href: (asset_path "favicon/favicon.ico"))
        meta(name: "msapplication-TileColor", content: "#da532c")
        meta(name: "theme-color", content: "#ffffff")
      end

      body class: "dark:bg-primary", data_controller: "theme" do
        main do
          render NavigationComponent.new
          div(class: "container mx-auto", &block)
          render FooterComponent.new
        end
        link href: "https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css", rel: "stylesheet"
      end
    end
  end
end
