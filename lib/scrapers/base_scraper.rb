module Scrapers
  class BaseScraper
    class InvalidResponse < StandardError; end

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

    def empty_results_allowed?
      false
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
