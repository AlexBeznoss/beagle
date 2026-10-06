require "test_helper"

class JobBoardTest < ActionDispatch::IntegrationTest
  test "home renders the layout and paginates ten visible jobs" do
    FactoryBot.create_list(:job_post, 12) # rubocop:disable FactoryBot/ExcessiveCreateList -- Pagination needs more than one page.
    hidden = FactoryBot.create(:job_post, hidden: true)

    get root_path
    assert_response :success
    assert_select "title", /BeagleJobs/
    assert_select "turbo-frame[id^=job_post_]", count: 10
    assert_select "a[href$='/?page=2']"
    assert_no_match hidden.name, response.body

    get root_path, params: {page: 2}
    assert_response :success
    assert_select "turbo-frame[id^=job_post_]", count: 2
    assert_select "a[href$='/?page=1']"
  end

  test "search uses the SQLite full text index and retains its query in pagination" do
    FactoryBot.create_list(:job_post, 11, name: "Rails developer") # rubocop:disable FactoryBot/ExcessiveCreateList -- Pagination needs more than one page.
    unrelated = FactoryBot.create(:job_post, name: "Python developer")

    get search_path, params: {search: {q: "Rails"}}
    assert_response :success
    assert_select "turbo-frame[id^=job_post_]", count: 10
    assert_no_match unrelated.name, response.body
    assert_select "a[href*='page=2'][href*='Rails']"

    get search_path, params: {search: {q: ""}}
    assert_response :success
    assert_select "turbo-frame[id^=job_post_]", count: 0
  end

  test "turbo frame requests render jobs without a second layout" do
    job = FactoryBot.create(:job_post)

    get root_path, headers: {"Turbo-Frame" => "job_posts"}
    assert_response :success
    assert_no_match(/<!DOCTYPE html>/i, response.body)
    assert_select "turbo-frame#job_posts", text: /#{job.name}/
  end

  test "search handles apostrophes and full text punctuation as literal text" do
    job = FactoryBot.create(:job_post, company: "O'Reilly", name: "C++ Rails developer")

    ["O'Reilly", "C++", "Rails developer"].each do |query|
      get search_path, params: {search: {q: query}}
      assert_response :success
      assert_select "turbo-frame#job_post_#{job.id}"
    end

    get search_path, params: {search: {q: '" OR -'}}
    assert_response :success
    assert_select "turbo-frame[id^=job_post_]", count: 0
  end

  test "authentication and admin endpoints are removed" do
    %w[/admin /bookmarks /job_posts/1/bookmarks].each do |path|
      assert_raises(ActionController::RoutingError) { get path }
    end
  end
end
