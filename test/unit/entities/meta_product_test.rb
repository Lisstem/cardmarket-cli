# frozen_string_literal: true

require 'concurrent'

require_relative '../../test_helper'

module CardmarketCLI
  module Entities
    class MetaProductTest < CardmarketTest
      @lock = Mutex.new
      @id = 0

      def self.meta_product_params
        params = MetaProduct::PARAMS.map { |p| [p, p] }.to_h
        params[:products] = []
        params
      end

      def self.from_json_hash_params(id = @product.value.id)
        params = meta_product_params.transform_values { |param| "#{param}_changed" }
        params[:id_metaproduct] = id
        params
      end

      def self.create_meta_product(account = nil, params = meta_product_params)
        MetaProduct.create("metaproduct #{new_id}", account, params)
      end

      def self.new_id
        @lock.synchronize do
          @id += 1
        end
      end

      def setup
        @meta_product = Concurrent::ThreadLocalVar.new { MetaProductTest.create_meta_product }
      end

      def teardown
        assert_equal @meta_product.value, MetaProduct.send(:remove, @meta_product.value.id)
      end

      test 'should have reader for all attributes' do
        (MetaProduct::PARAMS - [:products]).each do |param|
          assert_respond_to @meta_product.value, param
          assert_equal param, @meta_product.value.public_method(param).call
        end
        assert_respond_to @meta_product.value, :products
        assert_equal [], @meta_product.value.products
      end

      test 'should be meta' do
        assert @meta_product.value.meta?
      end

      test 'initialize should set updated_at' do
        assert_in_delta Time.now, @meta_product.value.updated_at
        assert Time.now > @meta_product.value.updated_at
      end

      test 'products should dub' do
        dub = @meta_product.value.products
        dub << :a
        refute_equal dub, @meta_product.value.products
      end

      # TODO: add the rest of the tests
    end
  end
end
