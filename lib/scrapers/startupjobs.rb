module Scrapers
  class Startupjobs < BaseScraper
    BASE_URL = "https://startup.jobs"
    HEADERS = {}
    # Free source access covers the last 14 days at 20 requests/minute.
    # See https://startup.jobs/mcp; use full access for historical backfills.
    MAX_PAGES = 100
    PAGINATION_FLAGS = [true, false].freeze

    def empty_results_allowed?
      true
    end

    def call
      client = StartupjobsClient.new
      jobs = {}
      %w[ruby rails].each do |query|
        cursor = nil
        seen_cursors = []
        MAX_PAGES.times do |index|
          arguments = {q: query, workplace_type: "remote", limit: 50}
          arguments[:cursor] = cursor if cursor
          data = client.search(arguments)
          unless data.is_a?(Hash) && data["jobs"].is_a?(Array) && PAGINATION_FLAGS.include?(data["has_more"])
            raise InvalidResponse, "StartupJobs invalid search page"
          end
          data["jobs"].each do |job|
            validate_job!(job)
            next unless job["workplace_type"] == "remote"
            # Search also matches company names; require a relevant role title.
            next unless RubyRelevance.call(title: job["title"], description: "")
            jobs[job["id"]] ||= normalize(job)
          end
          break unless data["has_more"]

          cursor = data["next_cursor"]
          unless cursor.is_a?(String) && cursor.present? && seen_cursors.exclude?(cursor) && data["jobs"].any?
            raise InvalidResponse, "StartupJobs invalid or repeated pagination cursor"
          end
          seen_cursors << cursor
          raise InvalidResponse, "StartupJobs pagination exceeded #{MAX_PAGES} pages" if index == MAX_PAGES - 1
        end
      end
      jobs.values
    end

    private

    def validate_job!(job)
      unless job.is_a?(Hash) && job["id"].is_a?(Integer) && job["id"].positive? && job["title"].is_a?(String) && job["title"].present? && job["company"].is_a?(Hash) && job["company"]["name"].is_a?(String) && job["company"]["name"].present? && %w[remote hybrid on-site].include?(job["workplace_type"]) && job["location"].is_a?(Hash)
        raise InvalidResponse, "StartupJobs invalid job schema"
      end
      uri = URI.parse(job.fetch("url"))
      unless uri.scheme == "https" && uri.host == "startup.jobs" && uri.userinfo.nil? && uri.path.match?(%r{\A/[^/]+-#{job["id"]}\z})
        raise InvalidResponse, "StartupJobs invalid job URL"
      end
      logo = job["company"]["logo_url"]
      raise InvalidResponse, "StartupJobs invalid company logo" unless logo.nil? || logo.is_a?(String)
      %w[city state country country_code].each do |field|
        value = job["location"][field]
        raise InvalidResponse, "StartupJobs invalid location" unless value.nil? || value.is_a?(String)
      end
    rescue KeyError, URI::InvalidURIError, TypeError
      raise InvalidResponse, "StartupJobs invalid job URL"
    end

    def normalize(job)
      uri = URI.parse(job["url"])
      uri.query = nil
      uri.fragment = nil
      place = job["location"]
      geography = [place["city"], place["state"], place["country"].presence || place["country_code"]].filter_map(&:presence).uniq
      {
        pid: uri.path.delete_prefix("/"),
        name: job["title"].strip,
        company: job["company"]["name"].strip,
        url: uri.to_s,
        img_url: job["company"]["logo_url"].presence,
        location: (["Remote"] + geography).join(", ")
      }
    end
  end
end
