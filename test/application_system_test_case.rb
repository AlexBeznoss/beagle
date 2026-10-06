require "test_helper"
require "support/chromedriver"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Rails re-registers its built-in :cuprite driver and discards our launch options.
  driven_by :beagle_cuprite
end
