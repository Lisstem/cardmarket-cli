# frozen_string_literal: true

require_relative '../../test_helper'

module CardmarketCLI
  module Entities
    ##
    # Wrapper with unique hash attribute.
    class HashChangeable
      extend Unique
      uniq_attr :hash, plural: :hashes, index: :to_s
    end

    ##
    # Wrapper with unique hash attribute.
    class ArrayChangeable
      extend Unique
      uniq_attr :array, hash: false
    end

    class UniqueTest < CardmarketTest
      def setup
        @hash = HashChangeable.new
        @array = ArrayChangeable.new
      end

      test 'should respond to brackets' do
        assert_respond_to @hash, :[]
        assert_respond_to @array, :[]
      end

      test 'should respond to reader' do
        assert_respond_to @hash, :hashes
        assert_respond_to @array, :arrays
      end

      test 'should not respond to add' do
        refute_respond_to @hash, :add
        refute_respond_to @array, :add
      end

      test 'should not respond to remove' do
        refute_respond_to @hash, :remove
        refute_respond_to @array, :remove
      end

      test 'should not respond to remove_at' do
        refute_respond_to @hash, :remove_at
        refute_respond_to @array, :remove_at
      end

      test 'should be able to add' do
        assert_equal :a, @hash.send(:add, :a)
        assert_equal :a, @array.send(:add, :a)
      end

      test 'should be able to remove' do
        assert_nil @hash.send(:remove, nil)
        assert_nil @hash.send(:remove, nil)
      end

      test 'hash attribute should not be able to remove_at' do
        assert_raises { @hash.send(:remove_at, 0) }
      end

      test 'array attribute should be able to remove_at' do
        assert_nil @array.send(:remove_at, 0)
      end

      test 'add should add' do
        assert_equal :a, @hash.send(:add, :a)
        assert_equal :a, @array.send(:add, :a)
        assert_equal :a, @hash['a']
        assert_equal :a, @array[-1]
      end

      test 'reader should dup' do
        @hash.send(:add, :a)
        @array.send(:add, :a)
        hashes = @hash.hashes
        hashes['b'] = :b
        arrays = @array.arrays << :b
        refute_equal hashes, @hash.hashes
        refute_equal arrays, @array.arrays
      end

      test 'remove should remove if present' do
        @hash.send(:add, :a)
        @array.send(:add, :a)
        assert_equal :a, @hash.send(:remove, 'a')
        assert_nil @hash['a']
        assert_equal :a, @array.send(:remove, :a)
        assert_nil @array[-1]
      end

      test 'remove should not remove if absent' do
        @hash.send(:add, :a)
        @array.send(:add, :a)
        assert_nil @hash.send(:remove, 'b')
        assert_equal :a, @hash['a']
        assert_nil @array.send(:remove, :b)
        assert_equal :a, @array[-1]
      end

      test 'remove_at should remove if present' do
        @array.send(:add, :a)
        @array.send(:add, :a)
        assert_equal :a, @array.send(:remove_at, 1)
        assert_nil @array[1]
      end

      test 'remove_at should not remove if absent' do
        @array.send(:add, :a)
        @array.send(:add, :a)
        assert_nil @array.send(:remove_at, 3)
        assert_equal :a, @array[1]
      end

      test 'reader returns all objects' do
        (0...n = 100).each do |i|
          @hash.send(:add, i)
          @array.send(:add, i)
        end
        assert_equal (0...n).to_a.map { |i| [i.to_s, i] }.to_h, @hash.hashes
        assert_equal (0...n).to_a, @array.arrays
      end
    end
  end
end
