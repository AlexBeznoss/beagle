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

    def raise_no_jobs!
      raise NoJobsFound.new("No jobs found on #{url}")
    end

    private

    attr_reader :page

    def url_query
      return unless page

      "page=#{page}"
    end
  end
end
