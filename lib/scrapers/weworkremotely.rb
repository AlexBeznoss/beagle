module Scrapers
  class Weworkremotely < BaseScraper
    BASE_URL = "https://weworkremotely.com/remote-jobs.rss"
    FEED_URLS = [
      BASE_URL,
      "https://weworkremotely.com/categories/remote-full-stack-programming-jobs.rss",
      "https://weworkremotely.com/categories/remote-back-end-programming-jobs.rss"
    ].freeze
    HEADERS = {Accept: "application/rss+xml, application/xml"}.freeze

    def call
      FEED_URLS.flat_map { |feed_url| jobs_from(feed_url) }.uniq { |job| job[:pid] }
    end

    def empty_results_allowed?
      true
    end

    private

    def jobs_from(feed_url)
      doc = Nokogiri::XML(RequestBody.call(feed_url, headers)) { |config| config.strict.nonet }
      channel = doc.at_xpath("/rss/channel")
      unless doc.internal_subset.nil? && channel && %w[title link description].all? { |field| channel.at_xpath(field)&.text&.strip&.present? }
        raise InvalidResponse, "Invalid WWR RSS channel at #{feed_url}"
      end

      channel.xpath("item").filter_map do |item|
        title = item.at_xpath("title")&.text.to_s.strip
        link = item.at_xpath("link")&.text.to_s.strip
        raise InvalidResponse, "WWR RSS item is missing title or link at #{feed_url}" if title.empty? || link.empty?

        canonical_url = canonical_url_from(link)
        company, separator, name = title.partition(": ")
        if separator.empty? || company.empty? || name.empty?
          raise InvalidResponse, "WWR RSS item has invalid company/title at #{feed_url}"
        end
        next if expired?(item)

        description = item.at_xpath("description")&.text.to_s
        next unless RubyRelevance.call(title: name, description: description)

        {
          pid: URI.parse(canonical_url).path.split("/").last,
          name: name,
          company: company,
          url: canonical_url,
          img_url: image_url_from(item),
          location: item.at_xpath("country")&.text&.strip&.presence || item.at_xpath("region")&.text&.strip&.presence
        }
      end
    rescue Nokogiri::XML::SyntaxError => error
      raise InvalidResponse, "Malformed WWR RSS at #{feed_url}: #{error.message}"
    end

    def expired?(item)
      expires_at = item.at_xpath("expires_at")&.text&.strip&.presence
      return false unless expires_at

      Time.rfc2822(expires_at) <= Time.current
    rescue ArgumentError
      raise InvalidResponse, "Invalid WWR expiration date: #{expires_at}"
    end

    def image_url_from(item)
      link = item.at_xpath("media:content", "media" => "http://search.yahoo.com/mrss")&.[]("url").presence
      return unless link

      uri = URI.parse(link)
      unless %w[http https].include?(uri.scheme) && uri.host.present? && uri.userinfo.nil?
        raise InvalidResponse, "Invalid WWR image URL: #{link}"
      end
      link
    rescue URI::InvalidURIError
      raise InvalidResponse, "Invalid WWR image URL: #{link}"
    end

    def canonical_url_from(link)
      uri = URI.parse(link)
      unless %w[http https].include?(uri.scheme) && uri.host&.downcase == "weworkremotely.com" &&
          uri.userinfo.nil? && uri.path.match?(%r{\A/remote-jobs/[^/]+/?\z})
        raise InvalidResponse, "Invalid WWR job URL: #{link}"
      end
      "https://weworkremotely.com#{uri.path.delete_suffix("/")}"
    rescue URI::InvalidURIError
      raise InvalidResponse, "Invalid WWR job URL: #{link}"
    end
  end
end
