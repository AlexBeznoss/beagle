require "test_helper"

class Scrapers::RequestBodyTest < ActiveSupport::TestCase
  describe ".call" do
    describe "when success" do
      test "returns body" do
        url = "https://fake.jobs.com"
        headers = {fake: "header"}
        body = "fake body"

        stub_request(:get, url).with(headers: headers).to_return(body:)

        result = Scrapers::RequestBody.call(url, headers)

        assert_equal result, body
      end
    end

    describe "when failure" do
      test "raises RequestError" do
        url = "https://fake.jobs.com"
        headers = {fake: "header"}
        status = 422
        body = "fake body"

        stub_request(:get, url).with(headers: headers).to_return(body:, status:)

        error = assert_raises Scrapers::RequestBody::RequestError do
          Scrapers::RequestBody.call(url, headers)
        end

        assert_equal url, error.url
        assert_equal status, error.status
        assert_equal body, error.body
        assert_equal "#{url} returned status #{status}", error.message
      end
    end
  end
end
