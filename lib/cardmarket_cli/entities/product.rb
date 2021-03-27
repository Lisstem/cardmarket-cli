# frozen_string_literal: true

require 'cardmarket_cli/entities/unique'
require 'cardmarket_cli/entities/entity'
require 'cardmarket_cli/logger'

module CardmarketCLI
  module Entities
    ##
    # See https://api.cardmarket.com/ws/documentation/API_2.0:Entities:Product
    class Product < Entity
      PARAMS = %i[en_name loc_name meta_product expansion_name rarity count_articles count_foils price_guide].freeze
      PATH_BASE = 'products'
      attr_r(*(PARAMS - [:price_guide]))
      attr_reader :updated_at

      def initialize(id, account, params = {})
        super(id, account, {})
        merge_params(params)
        Product.send(:add, self)
      end

      def meta?
        false
      end

      def read
        LOGGER.debug("Reading Product #{en_name}(#{id})")
        response = account.get("#{PATH_BASE}/#{id}")
        hash = JSON.parse(response.response_body)['product']
        hash['expansion_name'] ||= hash['expansion']&.[]('enName')
        Product.from_json_hash(account, hash)
      end

      def price_guide
        params[:price_guide].dup
      end

      private

      def merge_params(params)
        params[:price_guide]&.transform_keys! { |key| key.to_s.underscore.to_sym }&.delete(nil)
        self.params.merge!(params.slice(*PARAMS))
        self.params[:rarity] = self.params[:rarity]&.to_s&.downcase&.to_sym
        @updated_at = Time.now
        self
      end

      class << self
        extend Unique
        uniq_attr :instance

        private :new

        def from_json_hash(account, hash)
          hash.transform_keys! { |key| key.underscore.to_sym }
          hash[:meta_product] = MetaProduct.create(hash.delete(:id_metaproduct), account)
          product = Product.create(hash[:id_product], account, hash)
          hash[:meta_product]&.send(:merge_params, { products: [product] })
          product
        end

        def create(id, account, params = {})
          self[id]&.send(:merge_params, params) || new(id, account, params)
        end

        def search_all(account, search_string, exact: false)
          start = 0
          products = []
          loop do
            products.insert(-1, *search(account, search_string, start: start, exact: exact))
            break unless products.count >= start += 100
          end
          products
        end

        def search(account, search_string, start: 0, exact: false)
          response = account.get("#{PATH_BASE}/find", params: { search_all: search_string, exact: exact, start: start,
                                                                maxResults: 100, idGame: 1, idLanguage: 1 })
          results = []
          JSON.parse(response.response_body)['product']&.each do |product|
            results << from_json_hash(account, product)
          end
          results
        end
      end
    end
  end
end
