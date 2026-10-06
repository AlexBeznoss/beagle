require "test_helper"
require "support/component_helpers"

class PaginationComponentTest < ActiveSupport::TestCase
  include ComponentHelpers
  include ActiveSupport::Testing::TimeHelpers

  describe "when no prev and next" do
    test "returns empty" do
      pagy = OpenStruct.new(previous: nil, next: nil, page: 1)
      output = render PaginationComponent.new(pagy)

      assert output.children.blank?
    end
  end
end
