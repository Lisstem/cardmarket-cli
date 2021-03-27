# frozen_string_literal: true

require_relative '../../test_helper'

module CardmarketCLI
  module Entities
    class ProductTest < CardmarketTest
      def product_params
        params = Product::PARAMS.map { |p| [p, p] }.to_h
        params[:price_guide] = {}
        params
      end

      def setup
        super
        @product = Product.create(1, nil, product_params)
      end

      test 'should have reader for all attributes' do
        (Product::PARAMS - [:price_guide]).each do |param|
          assert_respond_to @product, param
          assert_equal param, @product.send(param)
        end
        assert_respond_to @product, :price_guide
        assert_equal({}, @product.price_guide)
      end

      test 'should not be meta' do
        assert_not @product.meta?
      end

      test 'rarity should downcase' do
        @product.send(:merge_params, { rarity: :NM })
        assert_equal :nm, @product.rarity
      end

      test 'initialize should set updated_at' do
        assert_in_delta Time.now, @product.updated_at
        assert Time.now > @product.updated_at
      end

      test 'price guide should dub' do
        product = Product.create(@product.id + 1, @account, { price_guide: {} })
        dub = product.price_guide
        dub[:a] = :a
        assert_not_equal product.price_guide, dub
      end

      test 'read updates attributes' do
        account = mock
        product = Product.create(265_535, account, product_params)
        new_params = product_params.transform_values { |param| "#{param}_changed" }
        new_params[:price_guide] = { new: 5, ex: 34 }
        new_params[:id_product] = product.id
        new_params[:rarity] = :rarity_changed
        response_mock = mock
        response_mock.expects(:response_body).once.returns({ product: new_params }.to_json)
        account.expects(:get).with("#{Product::PATH_BASE}/#{product.id}").once.returns(response_mock)

        product.read
        assert_in_delta Time.now, product.updated_at
        assert Time.now > product.updated_at

        (Product::PARAMS - [:meta_product]).each do |param|
          assert_equal new_params[param], product.send(param)
        end
      end

      test 'create should insert into list' do
        assert_equal @product, Product[@product.id]
      end
    end
  end
end
