module Scrapers
  class Brightdata
    ENDPOINT = "https://api.brightdata.com/request"
    ZONE = "rubyonremote"

    class RequestError < BaseScraper::InvalidResponse
      attr_reader :status

      def initialize(status)
        @status = status
        super("Bright Data RubyOnRemote request failed with status #{status}")
      end
    end

    def initialize(api_key: Rails.application.credentials.brightdata)
      unless api_key.is_a?(String) && api_key.present?
        raise BaseScraper::InvalidResponse, "Missing brightdata API key in Rails credentials"
      end
      @api_key = api_key
      @connection = Faraday.new do |client|
        client.options.open_timeout = 10
        client.options.timeout = 120
      end
    end

    def call(url)
      validate_url!(url)
      response = @connection.post(ENDPOINT) do |request|
        request.headers["Content-Type"] = "application/json"
        request.headers["Authorization"] = "Bearer #{@api_key}"
        request.body = JSON.generate(zone: ZONE, url: url, format: "json")
      end
      raise RequestError, response.status unless response.status == 200

      envelope = JSON.parse(response.body)
      unless envelope.is_a?(Hash) && envelope["status_code"].is_a?(Integer)
        raise BaseScraper::InvalidResponse, "Bright Data returned an invalid response envelope"
      end
      raise RequestError, envelope["status_code"] unless envelope["status_code"] == 200

      html = envelope["body"]
      unless html.is_a?(String) && html.present?
        raise BaseScraper::InvalidResponse, "Bright Data returned empty RubyOnRemote content"
      end
      doc = Nokogiri::HTML5.parse(html)
      if doc.at_css("title")&.text.to_s.match?(/just a moment|attention required|access denied/i) || doc.at_css("#challenge-running, #challenge-form")
        raise BaseScraper::InvalidResponse, "Bright Data returned a challenge page"
      end
      html
    rescue JSON::ParserError
      raise BaseScraper::InvalidResponse, "Bright Data returned malformed JSON"
    end

    private

    def validate_url!(url)
      uri = URI.parse(url)
      allowed_path = uri.path.match?(%r{\A/remote-ruby-jobs/?\z}) || uri.path.match?(%r{\A/jobs/[^/]+\z})
      unless uri.scheme == "https" && uri.host == "rubyonremote.com" && uri.userinfo.nil? && uri.port == 443 && uri.fragment.nil? && allowed_path
        raise BaseScraper::InvalidResponse, "Invalid RubyOnRemote acquisition URL"
      end
    rescue URI::InvalidURIError, TypeError
      raise BaseScraper::InvalidResponse, "Invalid RubyOnRemote acquisition URL"
    end
  end
end
