ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/rails"
require "webmock/minitest"
require "sidekiq/testing"

WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: [
    "api.clerk.dev",
    "chromedriver.storage.googleapis.com"
  ]
)

module SidekiqMinitestSupport
  def after_teardown
    Sidekiq::Worker.clear_all
    super
  end
end

module FaradayStubMethods
  def faraday_headers_with(headers = {})
    {
      "Accept" => "*/*",
      "Accept-Encoding" => /.*/,
      "User-Agent" => /Faraday.*/
    }.merge(headers)
  end
end

module UserData
  USERS = {
    default: {
      email: "user+clerk_test@beaglejobs.com",
      password: ">?AHEx@MzJ$J#(CE681W)"
    }
  }

  def users(name, field)
    USERS.dig(name, field)
  end
end

class ActiveSupport::TestCase
  include SidekiqMinitestSupport
  include FaradayStubMethods
  include UserData
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # Add more helper methods to be used by all tests here...
end
