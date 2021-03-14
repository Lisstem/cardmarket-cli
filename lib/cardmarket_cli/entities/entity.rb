# frozen_string_literal: true

module CardmarketCLI
  module Entities
    ##
    # Base for all entities in the API
    class Entity
      attr_reader :id

      def initialize(id, account, params = {})
        @id = id
        @params = params
        @account = account
      end

      protected

      attr_writer :id
      attr_accessor :account, :params

      class << self
        protected

        def attr_r(*symbols)
          symbols.each do |symbol|
            define_method symbol do
              @params[symbol]
            end
          end
        end
      end
    end
  end
end
