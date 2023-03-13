require "test_helper"
require "phlex/testing/rails/view_helper"
require "phlex/testing/nokogiri"

class PaginationComponentTest < ActiveSupport::TestCase
  include Phlex::Testing::Rails::ViewHelper
  include Phlex::Testing::Nokogiri::FragmentHelper
  include ActiveSupport::Testing::TimeHelpers

  describe "when no prev and next" do
    test "returns empty" do
      pagy = OpenStruct.new(prev: nil, next: nil, page: 1)
      output = render PaginationComponent.new(pagy)

      assert output.children.blank?
    end
  end
end
