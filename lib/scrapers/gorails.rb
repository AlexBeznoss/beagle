require "time"

module Scrapers
  class Gorails < BaseScraper
    BASE_URL = "https://jobs.gorails.com/jobs.xml"
    HEADERS = {"Accept" => "application/xml"}.freeze

    def empty_results_allowed?
      true
    end

    def call
      doc = Nokogiri::XML(request_body) { |config| config.strict.nonet }
      unless doc.root&.name == "jobs" && doc.root.namespace.nil? && doc.internal_subset.nil? &&
          doc.root.element_children.all? { |node| node.name == "job" && node.namespace.nil? }
        raise InvalidResponse, "Unrecognized GoRails XML feed"
      end

      doc.root.element_children.filter_map do |job|
        parsed = parse_job(job)
        expiry = text(job, "expires_at")
        next if expiry.present? && Time.iso8601(expiry) <= Time.current

        parsed
      end
    rescue Nokogiri::XML::SyntaxError, ArgumentError, URI::InvalidURIError => error
      raise InvalidResponse, "Invalid GoRails feed: #{error.message}"
    end

    private

    def parse_job(job)
      title = required_text(job, "title")
      company = required_text(job, "company_name")
      url = required_text(job, "url")
      uri = URI.parse(url)
      unless uri.scheme == "https" && uri.host == "jobs.gorails.com" &&
          uri.userinfo.nil? && uri.query.nil? && uri.fragment.nil? && uri.path.match?(%r{\A/jobs/[^/]+\z})
        raise InvalidResponse, "Invalid GoRails job URL"
      end

      limits = job.xpath("location_limits/location").map { |node| node.text.strip }.reject(&:empty?)
      {
        pid: uri.path.split("/").last,
        name: title,
        url: url,
        company: company,
        img_url: text(job, "company_logo_url").presence,
        location: limits.presence&.join(", ") || text(job, "location").presence || text(job, "location_type").presence
      }
    end

    def text(job, field)
      job.at_xpath(field)&.text.to_s.strip
    end

    def required_text(job, field)
      value = text(job, field)
      raise InvalidResponse, "GoRails job missing #{field}" if value.blank?

      value
    end
  end
end
