module Scrapers
  class RequestBody
    class RequestError < StandardError
      attr_reader :url, :status, :body

      def initialize(url, resp)
        @url = url
        @status = resp.status
        @body = resp.body

        super("#{url} returned status #{@status}")
      end
    end

    def self.call(url, headers)
      Faraday
        .get(url, nil, headers)
        .tap { |resp| raise RequestError.new(url, resp) unless resp.status == 200 }
        .body
        .force_encoding("UTF-8")
    end
  end
end
