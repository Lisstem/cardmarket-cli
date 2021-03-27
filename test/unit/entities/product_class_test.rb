# frozen_string_literal: true

require_relative '../../test_helper'
require_relative 'product_test'

module CardmarketCLI
  module Entities
    class ProductClassTest < ProductTest
      test 'create should create new product if it does not exist' do
        new_product = ProductTest.create_product(nil, {})
        assert new_product
        assert_not_equal @product.value, new_product
        assert_equal new_product, Product.send(:remove, new_product.id)
      end

      test 'create should insert new product into list ' do
        assert_equal @product.value, Product[@product.value.id]
      end

      test 'create should return old product if it already exists' do
        assert_equal @product.value, Product.create(@product.value.id, nil, {})
      end

      test 'create should update attributes if product already exists' do
        en_name = "#{@product.value.en_name}_changed"
        Product.create(@product.value.id, nil, { en_name: en_name })
        assert_equal en_name, @product.value.en_name
      end

      test 'from_json_hash should create new product' do
        product = Product.from_json_hash(nil, ProductTest.from_json_hash_params("#{@product.value.id} 4")
                                                         .transform_keys!(&:to_s))
        assert product
        assert_not_equal @product.value, product
        assert_equal product, Product.send(:remove, product.id)
      end

      test 'from_json_hash should create meta_product' do
        params = ProductTest.from_json_hash_params(ProductTest.new_id)
        params[:id_metaproduct] = 'product 1'
        product = Product.from_json_hash(nil, params.transform_keys!(&:to_s))
        meta_product = product.meta_product
        assert product
        assert meta_product
        assert meta_product.meta?
        assert_equal meta_product, MetaProduct[meta_product.id]
        assert_equal product, Product.send(:remove, product.id)
        assert_equal meta_product, MetaProduct.send(:remove, meta_product.id)
      end

      test 'search should query' do
        account = mock
        response_mock = mock
        response_mock.expects(:response_body).once.returns({ product: nil }.to_json)
        find = 'goyf'
        account.expects(:get).with("#{Product::PATH_BASE}/find",
                                   params: { search_all: 'goyf',
                                             exact: false,
                                             start: 0,
                                             maxResults: 100,
                                             idGame: 1,
                                             idLanguage: 1 }).once.returns(response_mock)

        assert Product.search(account, find)
      end

      test 'search should create products' do
        account = mock
        response_mock = mock
        response_mock.expects(:response_body)
                     .once
                     .returns({ product: (0...80).to_a.map! { |n| { id_product: "product search #{n}" } } }.to_json)
        find = 'goyf'
        account.expects(:get).with("#{Product::PATH_BASE}/find", params: { search_all: 'goyf', exact: false, start: 0,
                                                                           maxResults: 100, idGame: 1, idLanguage: 1 })
               .once.returns(response_mock)

        products = Product.search(account, find)
        assert_equal 80, products.count
        products.each do |product|
          assert_equal product, Product.send(:remove, product.id)
        end
      end

      test 'search_all should query multiple times' do
        account = mock
        response_mock = mock
        response_mock.expects(:response_body)
                     .once
                     .returns({ product: (0...100).to_a.map! { |n| { id_product: "product search all #{n}" } } }
                                .to_json)
        search_string = 'goyf'
        account.expects(:get).with("#{Product::PATH_BASE}/find", params: { search_all: 'goyf', exact: false, start: 0,
                                                                           maxResults: 100, idGame: 1, idLanguage: 1 })
               .once.returns(response_mock)
        response_mock = mock
        response_mock.expects(:response_body)
                     .once
                     .returns({ product: (100...150).to_a.map! { |n| { id_product: "product search all #{n}" } } }
                                .to_json)
        account.expects(:get).with("#{Product::PATH_BASE}/find", params: { search_all: 'goyf', exact: false, start: 100,
                                                                           maxResults: 100, idGame: 1, idLanguage: 1 })
               .once.returns(response_mock)

        products = Product.search_all(account, search_string)
        assert_equal 150, products.count
        products.each do |product|
          assert_equal product, Product.send(:remove, product.id)
        end
      end
    end
  end
end
