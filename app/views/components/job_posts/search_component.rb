# frozen_string_literal: true

class JobPosts::SearchComponent < ApplicationComponent
  include Phlex::Rails::Helpers::FormFor
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::ButtonTag

  def initialize(search_query)
    @search_query = search_query
  end

  def template
    form_for :search, method: :get, url: search_path, class: "flex flex-row pb-6 lg:pb-12" do |f|
      plain f.text_field :q,
        placeholder: "Search by job title, company, location...",
        value: @search_query,
        class: "w-full border border-primary bg-grey-lightest px-5 py-4 font-body font-light text-primary placeholder-primary transition-colors focus:border-secondary focus:outline-none focus:ring-2 focus:ring-secondary dark:border-secondary"
      button_tag data: {disable_with: "Loading..."},
        type: "submit",
        class: "mt-0 bg-secondary px-6 py-2 font-body text-2xl font-semibold text-white hover:bg-green" do
          i(class: "bx bx-search")
        end
    end
  end
end
