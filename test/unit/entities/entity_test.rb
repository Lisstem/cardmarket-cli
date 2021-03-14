# frozen_string_literal: true

require_relative '../../test_helper'

module CardmarketCLI
  module Entities
    class EntityTest < CardmarketTest
      def setup
        @entity = Entity.new(:id, :account, foo: :foo, bar: :bar)
        @entity.class.class_eval('attr_r :foo, :bar', __FILE__, __LINE__)
      end

      test 'has attr_r' do
        assert @entity.respond_to? :foo
        assert @entity.respond_to? :bar
      end

      test 'attr_r returns right value' do
        assert_equal :foo, @entity.foo
        assert_equal :bar, @entity.bar
      end

      test 'has id reader' do
        assert @entity.respond_to? :id
        assert_equal :id, @entity.id
      end

      test 'does not have id writer' do
        assert !@entity.respond_to?(:id=)
      end

      test 'does not have account getter and writer' do
        assert !@entity.respond_to?(:account)
        assert !@entity.respond_to?(:account=)
      end

      test 'does not have params getter and writer' do
        assert !@entity.respond_to?(:params)
        assert !@entity.respond_to?(:params=)
      end
    end
  end
end