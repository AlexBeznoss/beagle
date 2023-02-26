module Scrapers
  class BaseScraper
    def initialize(page = nil)
      @page = page
    end

    def url
      @_url ||= URI
        .parse(self.class::BASE_URL)
        .tap { |url| url.query = url_query }
        .to_s
    end

    def headers
      self.class::HEADERS
    end

    private

    attr_reader :page

    def request_body
      RequestBody.call(url, headers)
    end

    def url_query
      return unless page

      "page=#{page}"
    end
  end
end
