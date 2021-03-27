# frozen_string_literal: true

require 'concurrent'

require_relative '../../test_helper'

module CardmarketCLI
  module Entities
    class ProductTest < CardmarketTest
      @lock = Mutex.new
      @id = 0

      def self.product_params
        params = Product::PARAMS.map { |p| [p, p] }.to_h
        params[:price_guide] = {}
        params
      end

      def self.from_json_hash_params(id = @product.value.id)
        params = product_params.transform_values { |param| "#{param}_changed" }
        params[:price_guide] = { new: 5, ex: 34 }
        params[:id_product] = id
        params[:rarity] = :rarity_changed
        params
      end

      def self.create_product(account = nil, params = product_params)
        Product.create("product #{new_id}", account, params)
      end

      def self.new_id
        @lock.synchronize do
          @id += 1
        end
      end

      def setup
        @product = Concurrent::ThreadLocalVar.new { ProductTest.create_product }
      end

      def teardown
        assert_equal @product.value, Product.send(:remove, @product.value.id)
      end

      test 'should have reader for all attributes' do
        (Product::PARAMS - [:price_guide]).each do |param|
          assert_respond_to @product.value, param
          assert_equal param, @product.value.send(param)
        end
        assert_respond_to @product.value, :price_guide
        assert_equal({}, @product.value.price_guide)
      end

      test 'should not be meta' do
        assert_not @product.value.meta?
      end

      test 'rarity should downcase' do
        @product.value.send(:merge_params, { rarity: :NM })
        assert_equal :nm, @product.value.rarity
      end

      test 'initialize should set updated_at' do
        assert_in_delta Time.now, @product.value.updated_at
        assert Time.now > @product.value.updated_at
      end

      test 'price guide should dub' do
        dub = @product.value.price_guide
        dub[:a] = :a
        assert_not_equal @product.value.price_guide, dub
      end

      test 'read updates attributes' do
        account = mock
        product = ProductTest.create_product(account)
        new_params = ProductTest.from_json_hash_params(product.id)
        response_mock = mock
        response_mock.expects(:response_body).once.returns({ product: new_params }.to_json)
        account.expects(:get).with("#{Product::PATH_BASE}/#{product.id}").once.returns(response_mock)

        product.read
        assert_in_delta Time.now, product.updated_at
        assert Time.now > product.updated_at

        (Product::PARAMS - [:meta_product]).each do |param|
          assert_equal new_params[param], product.send(param)
        end
        assert_equal product, Product.send(:remove, product.id)
      end
    end
  end
end
