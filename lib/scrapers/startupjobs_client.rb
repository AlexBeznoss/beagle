module Scrapers
  class StartupjobsClient
    ENDPOINT = "https://api.startup.jobs/mcp"

    def initialize
      @request_id = 0
      @connection = Faraday.new do |connection|
        connection.options.open_timeout = 10
        connection.options.timeout = 30
      end
    end

    def search(arguments)
      result = request("tools/call", {name: "search_jobs", arguments: arguments})
      raise BaseScraper::InvalidResponse, "StartupJobs tool returned an error" if result["isError"]

      data = result["structuredContent"]
      unless data.is_a?(Hash)
        content = result["content"]
        texts = content.is_a?(Array) ? content.select { |item| item.is_a?(Hash) && item["type"] == "text" } : []
        raise BaseScraper::InvalidResponse, "StartupJobs missing tool data" unless texts.size == 1
        data = JSON.parse(texts.first.fetch("text"))
      end
      data
    rescue JSON::ParserError, KeyError, TypeError => e
      raise BaseScraper::InvalidResponse, "StartupJobs malformed tool data: #{e.message}"
    end

    private

    def request(method, params)
      @request_id += 1
      response = @connection.post(ENDPOINT) do |req|
        req.headers["Content-Type"] = "application/json"
        req.headers["Accept"] = "application/json, text/event-stream"
        req.body = JSON.generate(jsonrpc: "2.0", id: @request_id, method: method, params: params)
      end
      raise RequestBody::RequestError.new(ENDPOINT, response) unless response.status == 200

      if response.headers["content-type"].to_s.include?("text/event-stream")
        messages = response.body.split(/\r?\n\r?\n/).filter_map do |event|
          payload = event.lines.filter_map { |line| line.delete_prefix("data:").strip if line.start_with?("data:") }.join("\n")
          JSON.parse(payload) unless payload.empty?
        end
        message = messages.find { |item| item.is_a?(Hash) && item["id"] == @request_id }
      else
        message = JSON.parse(response.body)
      end
      unless message.is_a?(Hash) && message["jsonrpc"] == "2.0" && message["id"] == @request_id && !message.key?("error") && message["result"].is_a?(Hash)
        raise BaseScraper::InvalidResponse, "StartupJobs invalid JSON-RPC response"
      end
      message["result"]
    rescue JSON::ParserError, TypeError => e
      raise BaseScraper::InvalidResponse, "StartupJobs malformed response: #{e.message}"
    end
  end
end
