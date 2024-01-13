require "test_helper"
require "support/chromedriver"

Capybara.server = :falcon

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :ccuprite
end
