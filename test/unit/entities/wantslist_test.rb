# frozen_string_literal: true

require_relative '../../test_helper'

module CardmarketCLI
  module Entities
    class WantslistTest < CardmarketTest
      def self.list_params
        Wantslist::PARAMS.map { |p| [p, p] }.to_h
      end

      def setup
        @account = mock
        @list = Wantslist.new(1, @account, WantslistTest.list_params)
      end

      def teardown
        assert_equal @list, Wantslist.send(:remove, @list)
      end

      test 'should have reader for all attributes' do
        Wantslist::PARAMS.each do |param|
          assert_respond_to @list, param
          assert_equal param, @list.public_method(param).call
        end
      end

      test 'create adds list to instances' do
        assert_includes Wantslist.instances, @list
      end

      test 'path should have correct format' do
        assert_equal "#{Wantslist::PATH_BASE}/#{@list.id}", @list.path
      end

      test 'read should do nothing if id is nil' do
        list = Wantslist.new(nil, @account)
        @account.expects(:get).never
        assert_nil list.read
      end

      test 'read should query if id is given' do
        response = mock
        response.expects(:response_body).once.returns({ wantslist: {} }.to_json)
        @account.expects(:get).with(@list.path).once.returns(response)

        assert_equal response, @list.read
      end

      test 'read should update attributes' do
        response = mock
        new_name = 'name_changed'
        response.expects(:response_body).once
                .returns({ wantslist: { name: new_name } }.to_json)
        @account.expects(:get).with(@list.path).once.returns(response)
        item = WantslistItem.new(nil, nil, nil)
        @list.add_item(item)

        assert_equal response, @list.read
        assert_equal new_name, @list.name
      end

      test 'changed? should be false after read if id is given' do
        response = mock
        response.expects(:response_body).once
                .returns({ wantslist: { name: @list.name } }.to_json)
        @account.expects(:get).with(@list.path).once.returns(response)

        assert_equal response, @list.read
        refute @list.changed?
      end

      test 'read should clear items if id is given' do
        response = mock
        response.expects(:response_body).once
                .returns({ wantslist: {} }.to_json)
        @account.expects(:get).with(@list.path).once.returns(response)
        item = WantslistItem.new(nil, nil, nil)
        @list.add_item(item)

        assert_equal response, @list.read
        refute_includes @list.items, item
      end

      test 'read should add items if id is given' do
        response = mock
        response.expects(:response_body).once
                .returns({ wantslist: { item: (0...n = 100).to_a.map { |i| { idWant: i } } } }.to_json)
        @account.expects(:get).with(@list.path).once.returns(response)
        assert_equal response, @list.read
        assert_equal n, @list.items.count
      end

      # TODO: Tests for delete and update
      # TODO: Tests for class methods (read, update, from_hash)
    end
  end
end
