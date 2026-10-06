require "capybara/cuprite"

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [1400, 1400],
    headless: ENV.fetch("HEADLESS", "true") == "true",
    timeout: 30,
    process_timeout: 30,
    browser_options: {"no-sandbox" => nil, "disable-dev-shm-usage" => nil},
    logger: ENV["CI"] ? $stderr : nil
  )
end

Capybara.javascript_driver = :cuprite
Capybara.default_driver = :cuprite
