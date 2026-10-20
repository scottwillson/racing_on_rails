# frozen_string_literal: true

require File.expand_path("../test_helper", __dir__)

# :stopdoc:
class PasswordResetThrottleTest < ActiveSupport::TestCase
  test "allow requests under the limits" do
    with_cache do
      assert_not PasswordResetThrottle.throttled?("member@example.com", "10.0.0.1"), "Should not throttle first request"

      (PasswordResetThrottle::EMAIL_LIMIT - 1).times do
        PasswordResetThrottle.record "member@example.com", "10.0.0.1"
        assert_not PasswordResetThrottle.throttled?("member@example.com", "10.0.0.1"), "Should not throttle under EMAIL_LIMIT"
      end
    end
  end

  test "throttle by email" do
    with_cache do
      PasswordResetThrottle::EMAIL_LIMIT.times { PasswordResetThrottle.record "member@example.com", "10.0.0.1" }

      assert PasswordResetThrottle.throttled?("member@example.com", "10.0.0.1"), "Should throttle at EMAIL_LIMIT"
      assert PasswordResetThrottle.throttled?("  MEMBER@example.com ", "10.0.0.2"), "Should ignore case and whitespace, and apply from any IP"
      assert_not PasswordResetThrottle.throttled?("other@example.com", "10.0.0.2"), "Should not throttle a different email"
    end
  end

  test "throttle by IP" do
    with_cache do
      PasswordResetThrottle::IP_LIMIT.times do |index|
        PasswordResetThrottle.record "member.#{index}@example.com", "10.0.0.1"
      end

      assert PasswordResetThrottle.throttled?("new@example.com", "10.0.0.1"), "Should throttle at IP_LIMIT even for an email we haven't seen"
      assert_not PasswordResetThrottle.throttled?("new@example.com", "10.0.0.2"), "Should not throttle a different IP"
    end
  end

  test "expire counts" do
    with_cache do
      PasswordResetThrottle::EMAIL_LIMIT.times { PasswordResetThrottle.record "member@example.com", "10.0.0.1" }
      assert PasswordResetThrottle.throttled?("member@example.com", "10.0.0.1"), "Should throttle at EMAIL_LIMIT"

      travel PasswordResetThrottle::PERIOD + 1.minute do
        assert_not PasswordResetThrottle.throttled?("member@example.com", "10.0.0.1"), "Should throttle for only PERIOD"
      end
    end
  end

  test "reset" do
    with_cache do
      PasswordResetThrottle::EMAIL_LIMIT.times { PasswordResetThrottle.record "member@example.com", "10.0.0.1" }
      PasswordResetThrottle.reset "member@example.com", "10.0.0.1"

      assert_not PasswordResetThrottle.throttled?("member@example.com", "10.0.0.1"), "Should clear counts"
    end
  end
end
