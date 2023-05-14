require "test_helper"
require "phlex/testing/rails/view_helper"
require "phlex/testing/nokogiri"

class JobPosts::ListItemComponentTest < ActiveSupport::TestCase
  include Phlex::Testing::Rails::ViewHelper
  include Phlex::Testing::Nokogiri::FragmentHelper
  include ActiveSupport::Testing::TimeHelpers

  test "include basic info" do
    travel_to 2.days.ago
    job_post = FactoryBot.create(:job_post)
    travel_back
    output = render JobPosts::ListItemComponent.new(job_post, namespace: :job_posts)
    text = output.text

    assert_includes text, "Posted 2 days ago"
    assert_includes text, job_post.company
    assert_includes text, job_post.name
    assert_includes text, job_post.provider_label
  end

  describe "when logo saved to cloudflare" do
    test "shows cloudflare logo" do
      job_post = FactoryBot.create(:job_post, :with_logo)
      output = render JobPosts::ListItemComponent.new(job_post, namespace: :job_posts)
      link = output.at_css('[data-test-id="logo_link"]')
      img = link.at_css("img")

      assert_equal job_post.url, link[:href]
      assert_equal "_blank", link[:target]
      assert_equal controller.url_for(job_post.img), img[:src]
      assert_equal job_post.company, img[:alt]
    end
  end

  describe "when logo not saved to cloudflare" do
    test "shows logo from img_url" do
      img_url = "https://fake_image.url/logo.jpeg"
      job_post = FactoryBot.create(:job_post, img_url:)
      output = render JobPosts::ListItemComponent.new(job_post, namespace: :job_posts)
      link = output.at_css('[data-test-id="logo_link"]')
      img = link.at_css("img")

      assert_equal job_post.url, link[:href]
      assert_equal "_blank", link[:target]
      assert_equal img_url, img[:src]
      assert_equal job_post.company, img[:alt]
    end
  end
end
