ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/rails"
require "webmock/minitest"
require "support/user_helpers"

WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: ["api.clerk.dev"]
)

module FaradayStubMethods
  def faraday_headers_with(headers = {})
    {
      "Accept" => "*/*",
      "Accept-Encoding" => /.*/,
      "User-Agent" => /Faraday.*/
    }.merge(headers)
  end
end

class ActiveSupport::TestCase
  include FaradayStubMethods
  include UserHelpers
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # Add more helper methods to be used by all tests here...
end
