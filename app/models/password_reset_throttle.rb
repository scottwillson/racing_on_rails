# frozen_string_literal: true

# Throttle password reset emails.
#
# The password reset form will happily mail anyone we have an address for. Left unchecked, a
# spammer can loop over addresses and have our mail server send their traffic, which gets our
# domain suspended. Counters live in Rails.cache and expire on their own.
#
# Every attempt counts -- including ones for addresses we don't know -- so we cap both the mail
# sent to a single address and the number of addresses one host can walk through.
class PasswordResetThrottle
  # Per email address, per PERIOD
  EMAIL_LIMIT = 3

  # Per IP address, per PERIOD
  IP_LIMIT = 10

  PERIOD = 1.day

  class << self
    def throttled?(email, ip)
      count(email_key(email)) >= EMAIL_LIMIT || count(ip_key(ip)) >= IP_LIMIT
    end

    # Count an attempt, whether or not it matched an account
    def record(email, ip)
      increment email_key(email)
      increment ip_key(ip)
    end

    def reset(email, ip)
      Rails.cache.delete email_key(email)
      Rails.cache.delete ip_key(ip)
    end

    private

    def count(key)
      Rails.cache.read(key).to_i
    end

    # Stores that support atomic increment return the new value. FileStore and MemoryStore
    # return nil unless the key already exists, so seed it.
    def increment(key)
      Rails.cache.increment(key, 1, expires_in: PERIOD) || Rails.cache.write(key, 1, expires_in: PERIOD)
    end

    def email_key(email)
      key "email", email.to_s.strip.downcase
    end

    def ip_key(ip)
      key "ip", ip.to_s
    end

    # Hashed: these end up as file names under FileStore, and there's no reason to keep
    # members' email addresses lying around in tmp/cache
    def key(type, value)
      "password_reset_throttle/#{type}/#{Digest::SHA256.hexdigest(value)}"
    end
  end
end
