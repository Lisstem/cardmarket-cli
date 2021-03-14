# frozen_string_literal: true

require 'cardmarket_cli/entities/entity'

module CardmarketCLI
  module Entities
    ##
    # Base for all entities with changeable attributes in the API
    class Changeable < Entity
      def initialize(id, account, params)
        super(id, account, params)
        @changed = false
      end

      def changed?
        @changed
      end

      protected

      attr_writer :changed

      class << self
        protected

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
