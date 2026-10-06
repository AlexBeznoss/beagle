module Scrapers
  class Remoteok < BaseScraper
    BASE_URL = "https://remoteok.com/api"
    HEADERS = {Accept: "application/json"}
    HOSTS = %w[remoteok.com www.remoteok.com].freeze

    def call
      response = JSON.parse(request_body)
      raise InvalidResponse, "RemoteOK response is not a job array" unless response.is_a?(Array)

      response.filter_map do |job|
        raise InvalidResponse, "RemoteOK returned an invalid job" unless job.is_a?(Hash)
        next if job["legal"]
        validate_fields!(job)
        next unless RubyRelevance.call(title: job["position"], description: job["description"])
        validate_url!(job["url"])

        {
          pid: job["id"].to_s,
          name: job["position"].strip,
          url: job["url"],
          company: job["company"].strip,
          img_url: job["company_logo"].presence,
          location: job["location"]&.strip.presence
        }
      end.uniq { |job| job[:pid] }
    rescue JSON::ParserError, URI::InvalidURIError => e
      raise InvalidResponse, "RemoteOK returned malformed data: #{e.message}"
    end

    def empty_results_allowed?
      true
    end

    private

    def validate_fields!(job)
      required = %w[position url company].all? { |field| job[field].is_a?(String) && job[field].present? }
      optional = %w[location company_logo description].all? { |field| job[field].nil? || job[field].is_a?(String) }
      unless job["id"].to_s.match?(/\A[1-9]\d*\z/) && required && optional
        raise InvalidResponse, "RemoteOK job is missing required fields"
      end
    end

    def validate_url!(url)
      uri = URI.parse(url)
      unless uri.is_a?(URI::HTTPS) && HOSTS.include?(uri.host&.downcase) && uri.userinfo.nil? && uri.path.match?(%r{\A/(?:remote-jobs|jobs)/[^/]+\z})
        raise InvalidResponse, "RemoteOK job has an invalid URL"
      end
    end
  end
end
