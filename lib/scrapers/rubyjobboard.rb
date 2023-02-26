module Scrapers
  class Rubyjobboard < BaseScraper
    BASE_URL = "https://www.rubyjobboard.com/newest-ruby-on-rails-jobs"
    HEADERS = {}

    def call(body)
      doc = Nokogiri::HTML5.parse(body)

      doc.css("body #latest-jobs ul li .card").map do |job|
        next unless remote?(job)

        {
          pid: pid_from(job),
          name: name_from(job),
          url: url_from(job),
          company: company_from(job),
          img_url: image_url_from(job)
        }
      end.compact
    end

    private

    def pid_from(job)
      url_from(job).split("/").last
    end

    def name_from(job)
      job.at_css(".main a").text.strip
    end

    def url_from(job)
      URI.parse(BASE_URL)
        .tap { |url| url.path = job.at_css(".main a")[:href] }
        .to_s
    end

    def company_from(job)
      job.at_css(".logo img")[:alt].strip.gsub(" logo", "")
    end

    def image_url_from(job)
      job.at_css(".logo img")[:src]
    end

    def remote?(job)
      job.at_css(".main").text.include?("Remote")
    end
  end
end
