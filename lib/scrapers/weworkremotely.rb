module Scrapers
  class Weworkremotely < BaseScraper
    BASE_URL = "https://weworkremotely.com/remote-ruby-on-rails-jobs"
    HEADERS = {}

    def call
      doc = Nokogiri::HTML5.parse(request_body)

      doc.css("body #job_list section.jobs li").map do |job|
        next unless name_el(job)

        {
          pid: pid_from(job),
          name: name_from(job),
          url: url_from(job),
          company: company_from(job),
          img_url: image_url_from(job),
          location: location_from(job)
        }
      end.compact
    end

    private

    def pid_from(job)
      url_from(job).split("/").last
    end

    def url_from(job)
      URI.parse(BASE_URL)
        .tap { |url| url.path = name_el(job).parent[:href] }
        .to_s
    end

    def company_from(job)
      job.at_css("span.company").text.strip
    end

    def image_url_from(job)
      img = job.at_css("div.flag-logo")
      return unless img
      match = img[:style].match(/background-image:url\((.*)\)/)
      return unless match

      match[1]
    end

    def location_from(job)
      el = job.at_css("span.region.company")
      return unless el

      el.text.strip
    end

    def name_from(job)
      name_el(job).text.strip
    end

    def name_el(job)
      job.at_css("span.title")
    end
  end
end
