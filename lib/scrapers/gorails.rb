module Scrapers
  class Gorails < BaseScraper
    BASE_URL = "https://jobs.gorails.com/"
    HEADERS = {}
    LOCATION_SVG_PATH = "M12 2.25c-5.385 0-9.75 4.365-9.75 9.75s4.365 9.75 9.75 9.75 9.75-4.365 9.75-9.75S17.385 2.25 12 2.25zM6.262 6.072a8.25 8.25 0 1010.562-.766 4.5 4.5 0 01-1.318 1.357L14.25 7.5l.165.33a.809.809 0 01-1.086 1.085l-.604-.302a1.125 1.125 0 00-1.298.21l-.132.131c-.439.44-.439 1.152 0 1.591l.296.296c.256.257.622.374.98.314l1.17-.195c.323-.054.654.036.905.245l1.33 1.108c.32.267.46.694.358 1.1a8.7 8.7 0 01-2.288 4.04l-.723.724a1.125 1.125 0 01-1.298.21l-.153-.076a1.125 1.125 0 01-.622-1.006v-1.089c0-.298-.119-.585-.33-.796l-1.347-1.347a1.125 1.125 0 01-.21-1.298L9.75 12l-1.64-1.64a6 6 0 01-1.676-3.257l-.172-1.03z"

    def call(body)
      doc = Nokogiri::HTML5.parse(body)

      doc.css('body header ~ div ul[role="list"] li').map do |job|
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
      job.at_css("h3").text.strip
    end

    def url_from(job)
      URI.parse(BASE_URL)
        .tap { |url| url.path = job.at_css("a")[:href] }
        .to_s
    end

    def company_from(job)
      job.at_css("h3").parent.at_css("p").text.strip
    end

    def image_url_from(job)
      img = job.at_css("img")
      return unless img

      img[:src]
    end

    def location_from(job)
      icon = job.css("svg").find { |el| el.at_css("path")[:d] == LOCATION_SVG_PATH }.presence
      return unless icon

      icon.next_element.text.strip
    end
  end
end
