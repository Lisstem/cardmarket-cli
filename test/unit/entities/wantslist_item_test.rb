# frozen_string_literal: true

require_relative '../../test_helper'

module CardmarketCLI
  module Entities
    class WantslistItemTest < CardmarketTest
      def self.item_params
        params = WantslistItem::PARAMS.map { |p| [p, p] }.to_h
        params[:languages] = []
        params
      end

      def setup
        @product = mock
        @item = WantslistItem.new(1, @product, nil, WantslistItemTest.item_params)
      end

      test 'should have reader for all attributes' do
        (WantslistItem::PARAMS - [:languages]).each do |param|
          assert_respond_to @item, param
          assert_equal param, @item.public_method(param).call
        end
        assert_respond_to @item, :languages
        assert_equal [], @item.languages
      end

      test 'should have reader for product' do
        assert_respond_to @item, :product
        assert_equal @product, @item.product
      end

      test 'languages should be unique' do
        @item.languages = [1, 1]
        assert_equal [1], @item.languages
      end

      test 'languages with nil should set empty array' do
        @item.languages = nil
        assert_equal [], @item.languages
      end

      test 'meta? should return value of product.meta?' do
        @product.expects(:meta?).once.returns(false)
        refute @item.meta?
        @product.expects(:meta?).once.returns(true)
        assert @item.meta?
      end

      test 'to_xml_hash should return right hash' do
        hash = WantslistItemTest.item_params.transform_keys! { |key| key.to_s.camelize }
        hash.delete('languages')
        hash['idLanguage'] = [1]
        @item.languages << 1
        hash['idWant'] = @item.id
        assert_equal hash, @item.to_xml_hash
      end

      test 'to_xml_hash should remove blank values' do
        @item.languages = []
        @item.count = nil
        @item.min_condition = ''
        hash = @item.to_xml_hash
        refute_includes hash, 'languages'
        refute_includes hash, 'count'
        refute_includes hash, 'minCondition'
      end

      test 'to_xml_hash should add product id if id is nil' do
        item = WantslistItem.new(nil, @product, nil)
        @product.expects(:meta?).once.returns(false)
        @product.expects(:id).once.returns(:product)
        hash = item.to_xml_hash
        assert_equal :product, hash['idProduct']
        refute_includes hash, 'idWant'
        refute_includes hash, 'idMetaproduct'
        @product.expects(:meta?).once.returns(true)
        @product.expects(:id).once.returns(:meta_product)
        hash = item.to_xml_hash
        assert_equal :meta_product, hash['idMetaproduct']
        refute_includes hash, 'idWant'
        refute_includes hash, 'idProduct'
      end

      test 'from_hash should create WantslistItem' do
        hash = @item.to_xml_hash
        item = WantslistItem.from_hash(@item, hash)
        assert_equal @item.id, item.id
        assert_equal false, item.product
        assert_equal @item, item.send(:account)
        WantslistItem::PARAMS.each do |param|
          assert_equal @item.send(param), item.send(param)
        end
      end

      [Product, MetaProduct].each do |type|
        type_name = type.name.split('::')[-1]

        test "from_hash should create #{type_name}" do
          hash = @item.to_xml_hash
          hash['type'] = type_name.downcase
          product_id = 'WantslistItem create'
          hash[type_name.downcase] = { "id#{type_name.downcase.capitalize!}" => product_id }
          item = WantslistItem.from_hash(@item, hash)
          assert_equal type[product_id], item.product
          assert_equal type[product_id], type.send(:remove, product_id)
        end
      end
    end
  end
end
