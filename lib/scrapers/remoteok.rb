module Scrapers
  class Remoteok < BaseScraper
    BASE_URL = "https://remoteok.com/remote-ruby-jobs.json"
    HEADERS = {Accept: "application/json"}

    def parse(body)
      JSON.parse(body).each do |job|
        next if job["legal"]

        jobs.push(
          pid: job["id"],
          name: job["position"],
          url: job["url"],
          company: job["company"],
          img_url: job["company_logo"],
          location: job["location"].presence,
          posted_at: Date.parse(job["date"])
        )
      end
    end
  end
end
