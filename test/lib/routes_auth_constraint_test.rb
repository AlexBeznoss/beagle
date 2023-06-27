require "test_helper"

class RoutesAuthConstraintTest < ActiveSupport::TestCase
  FakeContext = Class.new do
    def initialize(env)
      @env = env
    end

    def constraints(guard)
      return unless guard.call(OpenStruct.new(env:))

      yield
    end

    private

    attr_reader :env
  end

  describe "#call" do
    describe "when no session claims" do
      test "not calls block" do
        env = {"clerk" => OpenStruct.new(session_claims: nil)}
        context = FakeContext.new(env)
        calls = []

        RoutesAuthConstraint.call(context, -> { calls.push(true) }) do
          calls.push(true)
        end

        assert_equal calls.count, 0
      end
    end

    describe "when authenticator returns false" do
      test "not calls block" do
        session_claims = "some fake claims"
        env = {"clerk" => OpenStruct.new(session_claims:)}
        context = FakeContext.new(env)
        calls = []
        rb_mock = Minitest::Mock.new
        rb_mock.expect :session_claims=, nil, [session_claims]
        rb_mock.expect :admin?, false

        Current.stub(:instance, rb_mock) do
          RoutesAuthConstraint.call(context, -> { Current.admin? }) do
            calls.push(true)
          end

          assert rb_mock
          assert_equal calls.count, 0
        end
      end
    end

    describe "when authenticator returns true" do
      test "calls block" do
        session_claims = "some fake claims"
        env = {"clerk" => OpenStruct.new(session_claims:)}
        context = FakeContext.new(env)
        calls = []
        rb_mock = Minitest::Mock.new
        rb_mock.expect :session_claims=, nil, [session_claims]
        rb_mock.expect :admin?, true

        Current.stub(:instance, rb_mock) do
          RoutesAuthConstraint.call(context, -> { Current.admin? }) do
            calls.push(true)
          end

          assert rb_mock
          assert_equal calls.count, 1
        end
      end
    end
  end
end
