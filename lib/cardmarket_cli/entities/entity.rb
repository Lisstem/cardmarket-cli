# frozen_string_literal: true

module CardmarketCLI
  module Entities
    ##
    # Base for all entites in the API
    class Entity
      def initialize(account)
        @changed = false
        @params = {}
        @account = account
      end

      def changed?
        @changed
      end

      class << self
        protected

        def attr_r(*symbols)
          symbols.each do |symbol|
            define_method symbol do
              @params[symbol]
            end
          end
        end

        def attr_(*symbols)
          attr_r(*symbols)
          symbols.each do |symbol|
            define_method "#{symbol}=" do |val|
              @params[symbol] = val
              @changed = true
            end
          end
        end
      end
    end
  end
end
