module Scrapers
  class Rubyonremote < BaseScraper
    BASE_URL = "https://rubyonremote.com"
    HEADERS = {Accept: "text/vnd.turbo-stream.html"}
    LOCATION_SVG_PATH = "M12,11.5A2.5,2.5 0 0,1 9.5,9A2.5,2.5 0 0,1 12,6.5A2.5,2.5 0 0,1 14.5,9A2.5,2.5 0 0,1 12,11.5M12,2A7,7 0 0,0 5,9C5,14.25 12,22 12,22C12,22 19,14.25 19,9A7,7 0 0,0 12,2Z"

    def call
      doc = Nokogiri::HTML5.fragment(request_body)

      doc.css('turbo-stream[target="job-listings"] li').map do |job|
        {
          pid: pid_from(job),
          name: name_from(job),
          url: url_from(job),
          company: company_from(job),
          img_url: image_url_from(job),
          location: location_from(job)
        }
      end
    end

    private

    def pid_from(job)
      url_from(job).split("/").last
    end

    def name_from(job)
      job.at_css("h2").text.strip
    end

    def url_from(job)
      URI.parse(BASE_URL)
        .tap { |url| url.path = job.at_css("a")[:href] }
        .to_s
    end

    def company_from(job)
      job.at_css("h2").next_element.text.strip
    end

    def image_url_from(job)
      img = job.at_css("img")
      img[:src] if img
    end

    def location_from(job)
      icon = job.css("svg").find { |el| el.at_css("path")[:d] == LOCATION_SVG_PATH }.presence
      return unless icon

      icon.parent.next_element.text.strip
    end
  end
end
