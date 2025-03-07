module Scrapers
  class Weworkremotely < BaseScraper
    BASE_URL = "https://weworkremotely.com/remote-ruby-on-rails-jobs"
    HEADERS = {}

    def call
      doc = Nokogiri::HTML5.parse(request_body)

      doc.css("body #job_list section.jobs li.new-listing-container").filter_map do |job|
        next unless name_el(job)

        {
          pid: pid_from(job),
          name: name_from(job),
          url: url_from(job),
          img_url: image_url_from(job),
        }
      end
    end

    private

    def pid_from(job)
      url_from(job).split("/").last
    end

    def url_from(job)
      URI.parse(BASE_URL)
        .tap { |url| url.path = find_parent(name_el(job), "a")&.[](:href) }
        .to_s
    end

    def company_from(job)
      job.at_css(".new-listing__company-name").text.strip
    end

    def image_url_from(job)
      img = job.at_css("div.tooltip--flag-logo div")
      return unless img

      match = img[:style].match(/background-image:url\((.*)\)/)
      return unless match

      match[1]
    end

    def name_from(job)
      name_el(job).text.strip
    end

    def name_el(job)
      job.at_css("h4.new-listing__header__title")
    end

    def find_parent(element, selector, max_depth: 10)
      return unless element
      return element if element.name == selector
      return unless max_depth.positive?

      find_parent(element.parent, selector, max_depth: max_depth - 1)
    end
  end
end
