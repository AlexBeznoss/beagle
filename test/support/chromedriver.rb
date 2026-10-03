require "capybara/cuprite"

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [1400, 1400],
    headless: ENV.fetch("HEADLESS", "true") == "true",
    timeout: 30,
    browser_options: {"no-sandbox" => nil}
  )
end

Capybara.javascript_driver = :cuprite
Capybara.default_driver = :cuprite
