require "application_system_test_case"

class BookmarksTest < ApplicationSystemTestCase
  test "user can add bookmarks from home page" do
    job_posts = FactoryBot.create_list(:job_post, 3)

    visit root_path
    login_as(:default)

    job_posts.each do |job_post|
      assert_text job_post.name
      assert_css "button[data-test-id=\"Bookmarks/#{job_post.id}/post\"]"
    end

    find("button[data-test-id=\"Bookmarks/#{job_posts.second.id}/post\"]").click

    assert_text I18n.t("bookmarks.created")
    assert_css "button[data-test-id=\"Bookmarks/#{job_posts.second.id}/delete\"]"
  end

  test "user can remove bookmarks from home page" do
    job_posts = FactoryBot.create_list(:job_post, 3)

    visit root_path
    login_as(:default)
    FactoryBot.create(
      :bookmark,
      job_post: job_posts.second,
      user_id: current_user_id
    )
    visit current_path

    assert_css "button[data-test-id=\"Bookmarks/#{job_posts.second.id}/delete\"]"
    assert_no_css "button[data-test-id=\"Bookmarks/#{job_posts.second.id}/post\"]"

    find("button[data-test-id=\"Bookmarks/#{job_posts.second.id}/delete\"]").click

    assert_text I18n.t("bookmarks.destroy")
    job_posts.each do |job_post|
      assert_css "button[data-test-id=\"Bookmarks/#{job_post.id}/post\"]"
    end
  end

  test "user can remove bookmarks from bookmarks page" do
    job_posts = FactoryBot.create_list(:job_post, 3)

    visit root_path
    login_as(:default)
    FactoryBot.create(
      :bookmark,
      job_post: job_posts.second,
      user_id: current_user_id
    )

    click_link "Bookmarks"

    assert_text job_posts.second.name
    assert_no_text job_posts.first.name
    assert_no_text job_posts.last.name

    assert_css "button[data-test-id=\"Bookmarks/#{job_posts.second.id}/delete\"]"
    find("button[data-test-id=\"Bookmarks/#{job_posts.second.id}/delete\"]").click

    assert_text I18n.t("bookmarks.destroy")

    job_posts.each do |job_post|
      assert_no_text job_post.name
    end
  end
end
