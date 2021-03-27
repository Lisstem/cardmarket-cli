# frozen_string_literal: true

require 'minitest/assertions'

module Minitest
  module Assertions
    def assert_not(test, msg = nil)
      msg = message(msg) do
        "Expected #{mu_pp test} to be falsy."
      end
      assert !test, msg
    end

    def assert_not_equal(not_exp, act, msg = nil)
      msg = message(msg) do
        "Actual was unexpected: #{not_exp.inspect}"
      end
      assert_not not_exp.equal?(act), msg
    end

    def assert_not_respond_to(obj, meth, msg = nil)
      msg = message(msg) do
        "Expected #{mu_pp(obj)} (#{obj.class}) to not respond to ##{meth}"
      end
      assert !obj.respond_to?(meth), msg
    end
  end
end
