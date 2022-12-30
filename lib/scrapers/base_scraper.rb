module Scrapers
  class NoJobsFound < StandardError; end

  class BaseScraper
    attr_reader :jobs

    def initialize(page = nil)
      @page = page
      @jobs = []
    end

    def url
      URI
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
