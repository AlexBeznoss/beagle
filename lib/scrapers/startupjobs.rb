module Scrapers
  class Startupjobs < BaseScraper
    BASE_URL = "https://startup.jobs"
    HEADERS = {}
    LINK_XPATH = './/div[last()][contains(@class, "flex")]/a'

    def call
      doc = Nokogiri::HTML5.parse(request_body)

      doc.css('.content-wrapper div[data-search-target="results"] .flex .grid').map do |job|
        {
          pid: pid_from(job),
          name: name_from(job),
          company: company_from(job),
          url: url_from(job),
          img_url: img_url_from(job)
        }
      end
    end

    private

    def pid_from(job)
      url_from(job).split("/").last
    end

    def name_from(job)
      job.at_xpath("#{LINK_XPATH}[1]")
        .inner_html.split("</span>").last.strip
    end

    def company_from(job)
      job.at_xpath("#{LINK_XPATH}[2]").text.strip
    end

    def url_from(job)
      URI.parse(BASE_URL)
        .tap { |url| url.path = job.at_xpath("#{LINK_XPATH}[1]")[:href] }
        .to_s
    end

    def img_url_from(job)
      job.at_css("img")[:src]
    end

    def request_body(count = 0)
      browser = Ferrum::Browser.new(url: Rails.application.credentials.browserless)
      browser.go_to("#{BASE_URL}/ruby-jobs")
      browser.at_css("#remote").click
      browser.network.wait_for_idle

      browser.body
    rescue Ferrum::TimeoutError => e
      raise e if count > 3
      sleep 1
      request_body(count + 1)
    ensure
      browser.reset
      browser.quit
    end
  end
end
