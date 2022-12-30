require "test_helper"

class Scrapers::ScrapeTest < ActiveSupport::TestCase
  describe ".call" do
    describe "when provider is not supported" do
      test "raises exception" do
        assert_raises(StandardError, "Provider nothing is not supported") do
          Scrapers::Scrape.call("nothing")
        end
      end
    end

    # TODO: finish specs
  end
end
