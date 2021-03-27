# frozen_string_literal: true

require_relative '../../test_helper'

module CardmarketCLI
  module Entities
    ##
    # Wrapper to create attribute accessors.
    class ChangeableWrapper < Changeable
      attr_ :foo, :bar
    end

    class ChangeableTest < CardmarketTest
      def setup
        @changeable = ChangeableWrapper.new(:id, :account, foo: :foo, bar: :bar)
      end

      test 'should have attr_r' do
        assert_respond_to @changeable, :foo
        assert_respond_to @changeable, :bar
      end

      test 'should have attr_w' do
        assert_respond_to @changeable, :foo=
        assert_respond_to @changeable, :bar=
      end

      test 'should respond to changed?' do
        assert_respond_to @changeable, :changed?
      end

      test 'should not change after new' do
        refute @changeable.changed?
      end

      test 'should change after attribute update' do
        @changeable.foo = :bar
        assert @changeable.changed?
      end

      test 'should not change if attribute updated with same value' do
        @changeable.bar = @changeable.bar
        refute @changeable.changed?
      end
    end
  end
end
