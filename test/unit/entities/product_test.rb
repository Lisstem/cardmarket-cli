# frozen_string_literal: true

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

      def self.from_json_hash_params(id = @product.id)
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
        @product = ProductTest.create_product
      end

      def teardown
        assert_equal @product, Product.send(:remove, @product.id)
      end

      test 'should have reader for all attributes' do
        (Product::PARAMS - [:price_guide]).each do |param|
          assert_respond_to @product, param
          assert_equal param, @product.public_method(param).call
        end
        assert_respond_to @product, :price_guide
        assert_equal({}, @product.price_guide)
      end

      test 'should not be meta' do
        refute @product.meta?
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
        dub = @product.price_guide
        dub[:a] = :a
        refute_equal dub, @product.price_guide
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

      # Tests for class
      test 'create without id should return nil' do
        assert_nil Product.create(nil, nil)
      end

      test 'create should create new product if it does not exist' do
        new_product = ProductTest.create_product(nil, {})
        assert new_product
        refute_equal @product, new_product
        assert_equal new_product, Product.send(:remove, new_product.id)
      end

      test 'create should insert new product into list ' do
        assert_equal @product, Product[@product.id]
      end

      test 'create should return old product if it already exists' do
        assert_equal @product, Product.create(@product.id, nil, {})
      end

      test 'create should update attributes if product already exists' do
        en_name = "#{@product.en_name}_changed"
        Product.create(@product.id, nil, { en_name: en_name })
        assert_equal en_name, @product.en_name
      end

      test 'from_json_hash should create new product' do
        product = Product.from_json_hash(nil, ProductTest.from_json_hash_params(ProductTest.new_id)
                                                         .transform_keys!(&:to_s))
        assert product
        refute_equal @product, product
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
        account.expects(:get).with("#{Product::PATH_BASE}/find", params: { search_all: 'goyf', exact: false, start: 0,
                                                                           maxResults: 100, idGame: 1, idLanguage: 1 })
               .once.returns(response_mock)

        assert Product.search(account, find)
      end

      test 'search should create products' do
        account = mock
        response_mock = mock
        response_mock.expects(:response_body)
                     .once
                     .returns({ product: (0...n = 80).to_a.map! { |i| { id_product: "product search #{i}" } } }.to_json)
        find = 'goyf'
        account.expects(:get).with("#{Product::PATH_BASE}/find", params: { search_all: 'goyf', exact: false, start: 0,
                                                                           maxResults: 100, idGame: 1, idLanguage: 1 })
               .once.returns(response_mock)

        products = Product.search(account, find)
        assert_equal n, products.count
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
                     .returns({ product: (100...n = 150).to_a.map! { |i| { id_product: "product search all #{i}" } } }
                                .to_json)
        account.expects(:get).with("#{Product::PATH_BASE}/find", params: { search_all: 'goyf', exact: false, start: 100,
                                                                           maxResults: 100, idGame: 1, idLanguage: 1 })
               .once.returns(response_mock)

        products = Product.search_all(account, search_string)
        assert_equal n, products.count
        products.each do |product|
          assert_equal product, Product.send(:remove, product.id)
        end
      end
    end
  end
end
