module Scrapers
  class Scrape
    JobData = Struct.new(
      :provider, :pid, :name, :url, :company,
      :img_url, :location, keyword_init: true
    )

    def self.call(...)
      new(...).call
    end

    def initialize(provider, page = nil)
      @provider = provider
      @page = page
    end

    def call
      body = RequestBody.call(scraper.url, scraper.headers)

      scraper.parse(body)
      scraper.raise_no_jobs! if scraper.jobs.empty?

      scraper.jobs.map do |job|
        JobData.new(provider:, **job)
      end
    end

    private

    attr_reader :provider, :page

    def scraper
      return @scraper if @scraper

      klass = case provider
      when "gorails" then Gorails
      when "remoteok" then Remoteok
      when "rubyjobboard" then Rubyjobboard
      when "rubyonremote" then Rubyonremote
      else
        raise "Provider #{provider} is not supported"
      end

      @scraper = klass.new(page)
    end
  end
end
