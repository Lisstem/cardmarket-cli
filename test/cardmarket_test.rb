# frozen_string_literal: true

require 'minitest/autorun'

module CardmarketCLI
  class CardmarketTest < Minitest::Test
    # Helper to define a test method using a String. Under the hood, it replaces
    # spaces with underscores and defines the test method.
    #
    #   test "verify something" do
    #     ...
    #   end
    # from ruby on rails, file: activesupport/lib/active_support/testing/declarative.rb, line 13
    def self.test(name, &block)
      test_name = "test_#{name.gsub(/\s+/, '_')}".to_sym
      defined = method_defined? test_name
      raise "#{test_name} is already defined in #{self}" if defined

      if block_given?
        define_method(test_name, &block)
      else
        define_method(test_name) do
          flunk "No implementation provided for #{name}"
        end
      end
    end
  end
end
