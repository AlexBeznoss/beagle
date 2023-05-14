require "capybara/cuprite"

Capybara.register_driver(:ccuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [1400, 1400],
    ignore_default_browser_options: true,
    timeout: 15,
    browser_options: {
      "no-sandbox" => nil,
      "disable-gpu" => nil,
      "hide-scrollbars" => nil,
      "mute-audio" => nil,
      "enable-automation" => nil,
      # NOTE: this option prevents clerk from working
      # "disable-web-security" => nil
      "disable-session-crashed-bubble" => nil,
      "disable-breakpad" => nil,
      "disable-sync" => nil,
      "no-first-run" => nil,
      "use-mock-keychain" => nil,
      "keep-alive-for-test" => nil,
      "disable-popup-blocking" => nil,
      "disable-extensions" => nil,
      "disable-hang-monitor" => nil,
      "disable-features" => "site-per-process,TranslateUI",
      "disable-translate" => nil,
      "disable-background-networking" => nil,
      "enable-features" => "NetworkService,NetworkServiceInProcess",
      "disable-background-timer-throttling" => nil,
      "disable-backgrounding-occluded-windows" => nil,
      "disable-client-side-phishing-detection" => nil,
      "disable-default-apps" => nil,
      "disable-dev-shm-usage" => nil,
      "disable-ipc-flooding-protection" => nil,
      "disable-prompt-on-repost" => nil,
      "disable-renderer-backgrounding" => nil,
      "force-color-profile" => "srgb",
      "metrics-recording-only" => nil,
      "safebrowsing-disable-auto-update" => nil,
      "password-store" => "basic",
      "no-startup-window" => nil
    }.tap do |options|
      options["headless"] = nil if ENV.fetch("HEADLESS", "true") == "true"
    end
  )
end

Capybara.javascript_driver = :ccuprite
Capybara.default_driver = :ccuprite
