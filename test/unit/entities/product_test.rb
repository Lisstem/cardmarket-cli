# frozen_string_literal: true

require_relative '../../test_helper'

module CardmarketCLI
  module Entities
    class ProductTest < APITest
      def setup
        super
        @account = Account.new('', '', '', '', site: 'https://test.example.org')
        params = Product::PARAMS.map { |p| [p, p] }.to_h
        params[:price_guide] = {}
        @product = Product.create(265_535, @account, params)
      end

      test 'is not meta' do
        assert_not @product.meta?
      end

      test 'price guide dubs' do
        product = Product.create(@product.id + 1, @account, { price_guide: {} })
        dub = product.price_guide
        dub[:a] = :a
        assert_not_equal product.price_guide, dub
      end

      test 'read updates values' do
        stub_url(@account.make_uri("#{Product::PATH_BASE}/#{@product.id}"), :get_product)
      end
    end
  end
end
