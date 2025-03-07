module Scrapers
  class Scrape
    class NoJobsFound < StandardError; end

    def self.call(...)
      new(...).call
    end

    def initialize(provider, page = nil)
      @provider = provider
      @page = page
    end

    def call
      scraper.call.tap do |jobs|
        raise_no_jobs!(scraper.url) if jobs.empty?
      end
    end

    private

    attr_reader :provider, :page

    def scraper
      return @scraper if @scraper

      klass = case provider
      when "gorails" then Gorails
      when "remoteok" then Remoteok
      when "rubyonremote" then Rubyonremote
      when "startupjobs" then Startupjobs
      when "weworkremotely" then Weworkremotely
      else
        raise "Provider #{provider} is not supported"
      end

      @scraper = klass.new(page)
    end

    def raise_no_jobs!(url)
      raise NoJobsFound.new("No jobs found on #{url}")
    end
  end
end
