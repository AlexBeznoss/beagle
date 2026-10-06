module Scrapers
  class Rubyonremote < BaseScraper
    class InvalidPage < BaseScraper::InvalidResponse; end

    BASE_URL = "https://rubyonremote.com/remote-ruby-jobs/"
    HEADERS = {}
    MAX_PAGES = 50
    LOCATION_SVG_PATH = "M12,11.5A2.5,2.5 0 0,1 9.5,9A2.5,2.5 0 0,1 12,6.5A2.5,2.5 0 0,1 14.5,9A2.5,2.5 0 0,1 12,11.5M12,2A7,7 0 0,0 5,9C5,14.25 12,22 12,22C12,22 19,14.25 19,9A7,7 0 0,0 12,2Z"

    def initialize(page = nil, client: Brightdata.new, cache: Rails.cache)
      super(page)
      @client = client
      @cache = cache
    end

    def call
      raise InvalidPage, "RubyOnRemote requires a full crawl from page one" unless page.nil? || page.to_s == "1"
      jobs = {}
      first_jobs, last_page, advertised_total = parse_listing(1)
      first_jobs.each { |job| jobs[job[:pid]] ||= job }
      current_page = 2
      while current_page <= last_page
        numbers = (current_page..[current_page + 3, last_page].min).to_a
        workers = numbers.map do |number|
          Thread.new do
            Thread.current.report_on_exception = false
            Rails.application.executor.wrap { parse_listing(number) }
          end
        end
        begin
          results = workers.map(&:value)
        ensure
          workers.each(&:join)
        end
        results.each do |page_jobs, advertised_last, page_total|
          advertised_total = [advertised_total, page_total].compact.max
          last_page = [last_page, advertised_last].max
          page_jobs.each { |job| jobs[job[:pid]] ||= job }
        end
        current_page = numbers.last + 1
      end
      if advertised_total && jobs.size < advertised_total
        raise InvalidPage, "RubyOnRemote catalog is incomplete: #{jobs.size} of #{advertised_total} jobs"
      end
      jobs.values
    end

    private

    def parse_listing(number)
      doc = document(@client.call(listing_url(number)))
      raise InvalidPage, "RubyOnRemote listing heading changed" unless doc.at_css("h1")&.text&.include?("Ruby Jobs")
      cards = doc.css("a[href]").select { |node| node.at_css("h2") && node["href"].include?("/jobs/") }
      raise InvalidPage, "RubyOnRemote listing unexpectedly contains no jobs" if cards.empty?
      last_page = [number, *advertised_pages(doc, number)].max
      raise InvalidPage, "RubyOnRemote catalog exceeds #{MAX_PAGES} pages" if last_page > MAX_PAGES
      total = doc.css("h3").filter_map { |heading| heading.text[/\A\s*(\d+) results total\s*\z/, 1] }.first&.to_i
      if number == 1 && total && total > cards.size && last_page == 1
        raise InvalidPage, "RubyOnRemote pagination is missing"
      end
      [cards.map { |card| parse_job(card) }, last_page, total]
    end

    def listing_url(number)
      (number == 1) ? BASE_URL : "#{BASE_URL}?page=#{number}"
    end

    def document(body)
      doc = Nokogiri::HTML5.parse(body)
      if doc.at_css("title")&.text&.match?(/Just a moment|Attention Required/i) || doc.at_css("#challenge-form, #cf-challenge-running")
        raise InvalidPage, "RubyOnRemote returned a challenge"
      end
      doc
    end

    def advertised_pages(doc, current)
      doc.css("a[href]").filter_map do |link|
        next unless link["href"].include?("page=")

        uri = URI.join(BASE_URL, link["href"])
        validate_origin!(uri)
        raise InvalidPage, "RubyOnRemote pagination path changed" unless uri.path.delete_suffix("/") == URI(BASE_URL).path.delete_suffix("/")
        params = URI.decode_www_form(uri.query.to_s)
        raise InvalidPage, "RubyOnRemote pagination query changed" unless params.size == 1 && params.first.first == "page" && params.first.last.match?(/\A[1-9]\d*\z/)
        number = params.first.last.to_i
        if link["rel"].to_s.split.include?("next") && number <= current
          raise InvalidPage, "RubyOnRemote pagination cycles backwards"
        end
        number
      rescue URI::InvalidURIError, ArgumentError
        raise InvalidPage, "RubyOnRemote pagination URL is invalid"
      end
    end

    def validate_origin!(uri)
      unless uri.scheme == "https" && uri.host == "rubyonremote.com" && uri.port == 443 && uri.userinfo.nil? && uri.fragment.nil?
        raise InvalidPage, "RubyOnRemote link leaves the provider"
      end
    end

    def parse_job(card)
      uri = URI.join(BASE_URL, card["href"])
      validate_origin!(uri)
      raise InvalidPage, "RubyOnRemote job URL changed" unless uri.path.match?(%r{\A/jobs/[^/]+\z}) && uri.query.nil?
      name = card.at_css("h2")&.text&.strip
      company = card.at_css("h2")&.next_element&.text&.strip
      raise InvalidPage, "RubyOnRemote job fields changed" if name.blank? || company.blank?
      location_icon = card.css("svg path").find { |path| path["d"] == LOCATION_SVG_PATH }
      location = location_icon&.parent&.parent&.next_element&.text&.strip.presence
      raise InvalidPage, "RubyOnRemote listing locations changed" if location.blank?
      job = {pid: uri.path.split("/").last, name: name, url: uri.to_s, company: company, img_url: card.at_css("img")&.[]("src"), location: location}
      job[:location] = full_location(job) if location&.match?(/\+\d+\s+more/)
      job
    rescue URI::InvalidURIError
      raise InvalidPage, "RubyOnRemote job URL is invalid"
    end

    def full_location(job)
      key = ["rubyonremote", "location", job[:pid], job[:location]]
      @cache.fetch(key, expires_in: 1.day) do
        doc = document(@client.call(job[:url]))
        title = doc.at_css("h1.schema-job-title")
        raise InvalidPage, "RubyOnRemote detail does not match listing" unless title&.text&.strip == job[:name]
        article = title.ancestors("article").first
        locations = article&.css("a.job-tags")&.filter_map do |tag|
          text = tag.text.strip
          text.delete_prefix("Remote - ") if text.start_with?("Remote - ")
        end
        raise InvalidPage, "RubyOnRemote detail locations changed" if locations.blank?
        locations.uniq.join(", ")
      end
    end
  end
end
