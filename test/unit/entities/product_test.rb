# frozen_string_literal: true

require 'test_helper'
require 'cardmarket_cli/account'
require 'cardmarket_cli/entities/product'

module CardmarketCLI
  module Entities
    class ProductTest < APITest
      def setup
        super
        @account = Account.new('', '', '', '')
        @product = Product.create(1, @account)
      end

      def teardown
        # Do nothing
      end

      test '' do
        assert_equal 1, @product.id
      end
    end
  end
end
