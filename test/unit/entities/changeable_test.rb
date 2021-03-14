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

      test 'has attr_r' do
        assert @changeable.respond_to? :foo
        assert @changeable.respond_to? :bar
      end

      test 'has attr_w' do
        assert @changeable.respond_to? :foo=
        assert @changeable.respond_to? :bar=
      end

      test 'has changed?' do
        assert @changeable.respond_to? :changed?
      end

      test 'has not changed after new' do
        assert_not @changeable.changed?
      end

      test 'has changed after attribute update' do
        @changeable.foo = :bar
        assert @changeable.changed?
      end

      test 'does not change if attribute updated with same value' do
        @changeable.bar = @changeable.bar
        assert_not @changeable.changed?
      end
    end
  end
end
