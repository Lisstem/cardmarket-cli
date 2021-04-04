# frozen_string_literal: true

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
        @meta_product = MetaProductTest.create_meta_product
      end

      def teardown
        assert_equal @meta_product, MetaProduct.send(:remove, @meta_product.id)
      end

      test 'should have reader for all attributes' do
        (MetaProduct::PARAMS - [:products]).each do |param|
          assert_respond_to @meta_product, param
          assert_equal param, @meta_product.public_method(param).call
        end
        assert_respond_to @meta_product, :products
        assert_equal [], @meta_product.products
      end

      test 'should be meta' do
        assert @meta_product.meta?
      end

      test 'initialize should set updated_at' do
        assert_in_delta Time.now, @meta_product.updated_at
        assert Time.now > @meta_product.updated_at
      end

      test 'products should dub' do
        dub = @meta_product.products
        dub << :a
        refute_equal dub, @meta_product.products
      end

      # Tests for the class
      test 'create without id should return nil' do
        assert_nil MetaProduct.create(nil, nil)
      end

      test 'create should create new meta product if it does not exist' do
        new_meta_product = MetaProductTest.create_meta_product(nil, {})
        assert new_meta_product
        refute_equal @meta_product, new_meta_product
        assert_equal new_meta_product, MetaProduct.send(:remove, new_meta_product.id)
      end

      test 'create should insert new meta product into list ' do
        assert_equal @meta_product, MetaProduct[@meta_product.id]
      end

      test 'create should return old meta product if it already exists' do
        assert_equal @meta_product, MetaProduct.create(@meta_product.id, nil, {})
      end

      test 'create should update attributes if product already exists' do
        en_name = "#{@meta_product.en_name}_changed"
        MetaProduct.create(@meta_product.id, nil, { en_name: en_name })
        assert_equal en_name, @meta_product.en_name
      end

      test 'from_json_hash should create new meta product' do
        meta_product = MetaProduct.from_json_hash(nil, MetaProductTest.from_json_hash_params(MetaProductTest.new_id)
                                                         .transform_keys!(&:to_s))
        assert meta_product
        refute_equal @meta_product, meta_product
        assert_equal meta_product, MetaProduct.send(:remove, meta_product.id)
      end

      test 'from_json_hash should create products' do
        params = MetaProductTest.from_json_hash_params(MetaProductTest.new_id)
        params[:product] = (0...100).to_a.map { |n| { 'id_product' => "metaproduct #{params[:id_metaproduct]} #{n}" } }
        meta_product = MetaProduct.from_json_hash(nil, params.transform_keys!(&:to_s))
        products = meta_product.products
        assert meta_product
        assert_equal 100, products.count
        products.each do |product|
          refute product.meta?
          assert_equal product, Product[product.id]
          assert_equal product, Product.send(:remove, product.id)
        end
        assert_equal meta_product, MetaProduct.send(:remove, meta_product.id)
      end

      test 'search should query' do
        account = mock
        response_mock = mock
        response_mock.expects(:response_body).once.returns({ meta_product: nil }.to_json)
        find = 'goyf'
        account.expects(:get).with("#{MetaProduct::PATH_BASE}/find", params: { search_all: 'goyf', exact: false,
                                                                               start: 0, maxResults: 100, idGame: 1,
                                                                               idLanguage: 1 })
               .once.returns(response_mock)

        assert MetaProduct.search(account, find)
      end

      test 'search should create meta products' do
        account = mock
        response_mock = mock
        response_mock.expects(:response_body).once.returns(
          { metaproduct: (0...80).to_a.map! { |n| { id_metaproduct: "meta product search #{n}" } } }.to_json
        )
        find = 'goyf'
        account.expects(:get).with("#{MetaProduct::PATH_BASE}/find", params: { search_all: 'goyf', exact: false,
                                                                               start: 0, maxResults: 100, idGame: 1,
                                                                               idLanguage: 1 })
               .once.returns(response_mock)

        meta_products = MetaProduct.search(account, find)
        assert_equal 80, meta_products.count
        meta_products.each do |meta_product|
          assert_equal meta_product, MetaProduct.send(:remove, meta_product.id)
        end
      end

      test 'search_all should query multiple times' do
        account = mock
        response_mock = mock
        response_mock.expects(:response_body).once.returns(
          { metaproduct: (0...100).to_a.map! { |n| { id_metaproduct: "meta product search all #{n}" } } }.to_json
        )
        search_string = 'goyf'
        account.expects(:get).with("#{MetaProduct::PATH_BASE}/find", params: { search_all: 'goyf', exact: false,
                                                                               start: 0, maxResults: 100, idGame: 1,
                                                                               idLanguage: 1 })
               .once.returns(response_mock)
        response_mock = mock
        response_mock.expects(:response_body).once.returns(
          { metaproduct: (100...150).to_a.map! { |n| { id_metaproduct: "product search all #{n}" } } }.to_json
        )
        account.expects(:get).with("#{MetaProduct::PATH_BASE}/find", params: { search_all: 'goyf', exact: false,
                                                                               start: 100, maxResults: 100, idGame: 1,
                                                                               idLanguage: 1 })
               .once.returns(response_mock)

        meta_products = MetaProduct.search_all(account, search_string)
        assert_equal 150, meta_products.count
        meta_products.each do |meta_product|
          assert_equal meta_product, MetaProduct.send(:remove, meta_product.id)
        end
      end
    end
  end
end
