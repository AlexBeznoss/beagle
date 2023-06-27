require "test_helper"

class CurrentTest < ActiveSupport::TestCase
  describe "session_claims=" do
    test "assigns user_id and session_id" do
      session = {"sub" => "fake_user_id", "sid" => "fake_session_id"}

      Current.session_claims = session

      assert_equal "fake_user_id", Current.user_id
      assert_equal "fake_session_id", Current.session_id
    end
  end

  describe "user" do
    test "returns user from clerk sdk" do
      user_id = "fake_user_id"
      user = "SomeFakeUser"
      session = {"sub" => user_id}
      user_sdk_mock = Minitest::Mock.new
      user_sdk_mock.expect :find, user, [user_id]
      sdk_mock = Minitest::Mock.new
      sdk_mock.expect :users, user_sdk_mock

      Clerk::SDK.stub :new, sdk_mock do
        Current.session_claims = session
        result = Current.user

        assert_equal user, result
        assert user_sdk_mock
        assert sdk_mock
      end
    end
  end

  describe "session" do
    test "returns session from clerk sdk" do
      session_id = "fake_session_id"
      expected_session = "SomeFakeSerssion"
      session = {"sid" => session_id}
      session_sdk_mock = Minitest::Mock.new
      session_sdk_mock.expect :find, expected_session, [session_id]
      sdk_mock = Minitest::Mock.new
      sdk_mock.expect :sessions, session_sdk_mock

      Clerk::SDK.stub :new, sdk_mock do
        Current.session_claims = session
        result = Current.session

        assert_equal expected_session, result
        assert session_sdk_mock
        assert sdk_mock
      end
    end
  end

  describe "verified?" do
    describe "when session is not assigned" do
      test "returns false" do
        assert_not Current.verified?
      end
    end

    describe "when session assigned" do
      test "returns trie" do
        session = {"sub" => "fake_user_id", "sid" => "fake_session_id"}

        Current.session_claims = session

        assert Current.verified?
      end
    end
  end

  describe "admin?" do
    describe "when is admin" do
      test "returns true" do
        user = {"private_metadata" => {"role" => "admin"}}

        Current.instance.stub :user, user do
          assert Current.admin?
        end
      end
    end

    describe "when is NOT admin" do
      test "returns false" do
        user = {"private_metadata" => {}}

        Current.instance.stub :user, user do
          assert_not Current.admin?
        end
      end
    end
  end
end
