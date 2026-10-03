require "application_system_test_case"

class JobBoardBrowserTest < ApplicationSystemTestCase
  setup do
    # Public UI checks never send credentials or requests to external services.
    page.driver.browser.url_allowlist = [%r{\Ahttp://(?:localhost|127\.0\.0\.1):\d+/}]
  end

  teardown do
    page.driver.browser.url_allowlist = []
  end

  test "search and pagination work through Turbo" do
    jobs = FactoryBot.create_list(:job_post, 11, name: "Rails developer") # rubocop:disable FactoryBot/ExcessiveCreateList -- Pagination needs more than one page.
    unrelated = FactoryBot.create(:job_post, name: "Python developer")

    visit root_path
    assert_selector "turbo-frame[id^=job_post_]", count: 10
    fill_in "search_q", with: "Rails"
    find("form[action='/search'] button[type=submit]").click
    assert_selector "turbo-frame[id^=job_post_]", count: 10
    assert_no_text unrelated.name
    find("a[href*='page=2']").click
    assert_selector "turbo-frame[id^=job_post_]", count: 1
    assert_text jobs.first.name
    assert_equal "Rails", find_by_id("search_q").value
  end

  test "theme persists on desktop and mobile" do
    visit root_path
    assert_selector "[data-theme-target=icon].bxs-moon, [data-theme-target=icon].bxs-sun", visible: :all
    original_theme = evaluate_script("localStorage.theme")
    click_button "Switch theme"
    assert_selector "html#{(original_theme == "dark") ? ":not(.dark)" : ".dark"}"
    visit root_path
    assert_selector "html#{(original_theme == "dark") ? ":not(.dark)" : ".dark"}"

    page.driver.resize(390, 844)
    click_button "Switch theme"
    assert_selector "html#{(original_theme == "dark") ? ".dark" : ":not(.dark)"}"
    assert_no_button "Sign in"
    assert_no_link "Bookmarks"
  end
end
