module Scrapers
  class Remoteok < BaseScraper
    BASE_URL = "https://remoteok.com/remote-ruby-jobs.json"
    HEADERS = {Accept: "application/json"}

    def call
      JSON.parse(request_body).map do |job|
        next if job["legal"]

        {
          pid: job["id"],
          name: job["position"],
          url: job["url"],
          company: job["company"],
          img_url: job["company_logo"],
          location: job["location"].presence
        }
      end.compact
    end
  end
end
