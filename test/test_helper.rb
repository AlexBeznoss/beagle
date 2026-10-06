ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/rails"
require "webmock/minitest"

WebMock.disable_net_connect!(allow_localhost: true)

# Create FTS tables before transactions can roll their creation back.
JobPost.configure_search_index

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

  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  parallelize_setup do
    JobPost.configure_search_index
  end

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # Add more helper methods to be used by all tests here...
end
