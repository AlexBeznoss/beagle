require "application_system_test_case"

class BookmarksTest < ApplicationSystemTestCase
  test "user can add and remove bookmarks on home page" do
    job_posts = FactoryBot.create_list(:job_post, 3)
    for_bookmark = job_posts.second
    others = [job_posts.first, job_posts.last]

    visit root_path
    login_as(:default)

    job_posts.each do |job_post|
      assert_text job_post.name
      assert_css "button[data-test-id=\"Bookmarks/#{job_post.id}/post\"]"
    end

    find("button[data-test-id=\"Bookmarks/#{for_bookmark.id}/post\"]").click

    assert_text I18n.t("bookmarks.created")
    others.each do |jp|
      assert_css "button[data-test-id=\"Bookmarks/#{jp.id}/post\"]"
    end
    assert_css "button[data-test-id=\"Bookmarks/#{for_bookmark.id}/delete\"]"
    find("button[data-test-id=\"Bookmarks/#{for_bookmark.id}/delete\"]").click
    assert_text I18n.t("bookmarks.destroy")
    job_posts.each do |job_post|
      assert_css "button[data-test-id=\"Bookmarks/#{job_post.id}/post\"]"
    end
  end

  test "user can remove bookmarks from bookmarks page" do
    job_posts = FactoryBot.create_list(:job_post, 3)
    FactoryBot.create(
      :bookmark,
      job_post: job_posts.second,
      user_id: users(:default, :id)
    )

    visit root_path
    login_as(:default)

    click_link_or_button "Bookmarks"

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
