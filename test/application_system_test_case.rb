require "test_helper"
require "capybara/cuprite"

Capybara.register_driver(:ccuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    headless: false,
    window_size: [1400, 1400],
    browser_options: {"no-sandbox": nil}
  )
end

Capybara.javascript_driver = :ccuprite
Capybara.default_driver = :ccuprite

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :ccuprite
end
