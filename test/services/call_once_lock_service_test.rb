require "test_helper"

class CallOnceLockServiceTest < ActiveSupport::TestCase
  describe ".call" do
    describe "when locked" do
      test "not calls passed block" do
        lock_name = "fake lock name"
        timeout = 312
        redis_mock = Minitest::Mock.new
        redis_mock.expect :set, false do |ln, value, **kwargs|
          ln == lock_name &&
            value == true &&
            kwargs[:ex] == timeout &&
            kwargs[:nx] == true
        end
        block_mock = Minitest::Mock.new
        block_mock.expect :call, nil

        Redis.stub :new, redis_mock do
          CallOnceLockService.call(lock_name, timeout:) do
            block_mock.call
          end
        end

        assert_mock redis_mock
        assert_raises MockExpectationError do
          block_mock.verify
        end
      end
    end

    describe "when unlocked" do
      test "calls passed block" do
        lock_name = "fake lock name"
        redis_mock = Minitest::Mock.new
        redis_mock.expect :set, true do |ln, value, **kwargs|
          ln == lock_name &&
            value == true &&
            kwargs[:ex] == 30 &&
            kwargs[:nx] == true
        end
        block_mock = Minitest::Mock.new
        block_mock.expect :call, nil

        Redis.stub :new, redis_mock do
          CallOnceLockService.call(lock_name) do
            block_mock.call
          end
        end

        assert_mock redis_mock
        assert_mock block_mock
      end
    end
  end
end
