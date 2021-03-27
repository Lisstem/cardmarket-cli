# frozen_string_literal: true

require_relative '../../test_helper'

module CardmarketCLI
  module Entities
    ##
    # Wrapper to create attribute accessors.
    class DeletableWrapper
      extend Deletable
      list_attr :hash, plural: :hashes, hash: true
      list_attr :array
    end

    class OptionsDeletable
      extend Deletable
      list_attr :default, default: true
      list_attr :without_suffix, plural: :without_suffixes, suffix: false
      list_attr :different_name, add: :insert, delete: :remove
    end

    class DeletableTest < CardmarketTest
      def setup
        @deletable = DeletableWrapper.new
        @options = OptionsDeletable.new
      end

      def add(key, value = key)
        if key.nil?
          assert_nil @deletable.send(:add_hash, [key, value])
          assert_nil @deletable.send(:add_array, key)
        else
          assert_equal({ key => value }, @deletable.send(:add_hash, [key, value]))
          assert_equal key, @deletable.send(:add_array, key)
        end
      end

      def delete(index, expected = index)
        if expected.nil?
          assert_nil @deletable.send(:delete_hash, index)
          assert_nil @deletable.send(:delete_array, index)
        else
          assert_equal expected, @deletable.send(:delete_hash, index)
          assert_equal expected, @deletable.send(:delete_array, index)
        end
      end

      test 'should respond to modifiers' do
        %i[add_hash delete_hash add_array delete_array].each do |m|
          assert_respond_to @deletable, m
        end
        %i[delete insert_different_name remove_different_name].each do |m|
          assert_respond_to @options, m
        end
      end

      test 'should respond to readers' do
        %i[hashes deleted_hashes arrays deleted_arrays].each do |m|
          assert_respond_to @deletable, m
        end
      end

      test 'should not respond to brackets without default' do
        refute_respond_to @deletable, :[]
      end

      test 'should respond to brackets with default' do
        assert_respond_to @options, :[]
      end

      test 'should not respond to clear' do
        refute_respond_to @deletable, :clear_hashes
        refute_respond_to @deletable, :clear_arrays
        refute_respond_to @options, :clear
      end

      test 'should be able to clear' do
        @deletable.send(:clear_hashes)
        @deletable.send(:clear_arrays)
        @options.send(:clear)
      end

      test 'add should add' do
        add(:a)
        assert_equal :a, @deletable.send(:add_array, :a)
        assert_equal :a, @deletable.arrays[-1]
      end

      test 'add should return nil if hash and key is nil' do
        assert_nil @deletable.send(:add_hash, [nil, :a])
        assert_nil @deletable.send(:add_hash, [nil, nil])
      end

      test 'delete should delete' do
        add(:a)
        delete(:a)
        refute_includes @deletable.hashes, :a
        refute_includes @deletable.arrays, :a
      end

      test 'delete should add to deleted' do
        add(:a)
        delete(:a)
        assert_includes @deletable.deleted_hashes, :a
        assert_includes @deletable.deleted_arrays, :a
      end

      test 'delete should not add to deleted if not present' do
        add(:a)
        delete(:a)
        refute_includes @deletable.deleted_hashes, :b
        refute_includes @deletable.deleted_hashes, nil
        refute_includes @deletable.deleted_arrays, :b
        refute_includes @deletable.deleted_arrays, nil
      end

      test 'delete should return nil if not present' do
        add(:a)
        delete(:b, nil)
      end

      test 'add should remove added from deleted' do
        add(:a)
        delete(:a)
        add(:a)
        refute_includes @deletable.deleted_hashes, :a
        refute_includes @deletable.deleted_arrays, :a
      end

      test 'readers should dup' do
        %i[hashes deleted_hashes arrays deleted_arrays].each do |m|
          collection = @deletable.public_method(m).call
          collection[0] = 0
          refute_equal collection, @deletable.public_method(m).call
        end
      end

      test 'brackets should return right value' do
        assert_nil @options[0]
        @options.send(:add_default, :a)
        assert_equal :a, @options[-1]
      end

      test 'clear should clear added' do
        add(:a)
        @deletable.send(:clear_hashes)
        @deletable.send(:clear_arrays)
        assert_empty @deletable.hashes
        assert_empty @deletable.arrays
      end

      test 'clear should clear deleted' do
        add(:a)
        delete(:a)
        @deletable.send(:clear_hashes)
        @deletable.send(:clear_arrays)
        assert_empty @deletable.deleted_hashes
        assert_empty @deletable.deleted_arrays
      end
    end
  end
end
