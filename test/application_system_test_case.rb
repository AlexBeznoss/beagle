require "test_helper"
require "support/chromedriver"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :cuprite
end
