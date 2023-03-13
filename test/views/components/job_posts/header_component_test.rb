require "test_helper"
require "phlex/testing/rails/view_helper"
require "phlex/testing/nokogiri"

class JobPosts::HeaderComponentTest < ActiveSupport::TestCase
  include Phlex::Testing::Rails::ViewHelper
  include Phlex::Testing::Nokogiri::FragmentHelper

  test "include home link" do
    output = render JobPosts::HeaderComponent.new
    link = output.at_css("h1 a")

    assert_equal "BeagleJobs", link.text
    assert_equal "/", link[:href]
  end

  test "include description" do
    output = render JobPosts::HeaderComponent.new
    expected_description =
      "Accurate list of Remote Ruby jobs from RubyJobBoard, GoRails Jobs, RemoteOK, RubyOnRemote, WeWorkRemotely and StartupJobs."

    assert_equal expected_description, output.at_css("p").text
  end

  test "include logo" do
    output = render JobPosts::HeaderComponent.new

    assert_equal view_context.asset_path("logo.svg"), output.at_css("img")[:src]
  end
end
