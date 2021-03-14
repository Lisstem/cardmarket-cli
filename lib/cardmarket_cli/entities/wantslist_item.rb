# frozen_string_literal: true

require 'cardmarket_cli/entities/changeable'
require 'cardmarket_cli/entities/product'
require 'cardmarket_cli/entities/meta_product'
require_relative '../util/string'

module CardmarketCLI
  module Entities
    ##
    # see https://api.cardmarket.com/ws/documentation/API_2.0:Wantslist_Item
    class WantslistItem < Changeable
      PARAMS = %i[count from_price min_condition wish_price mail_alert languages is_foil is_altered is_playset is_signed
                  is_first_ed].freeze
      attr_(*(PARAMS - [:languages]))
      attr_reader :product

      def initialize(id, product, account, params = {})
        params = { count: 1, min_condition: :PO, wish_price: 0.0, mail_alert: false, languages: [1], is_foil: nil,
                   is_altered: nil, is_playset: nil, is_signed: nil, is_first_ed: nil, from_price: nil }.merge!(params)
        super(id, account, params.slice(*PARAMS))
        @product = product
      end

      def to_xml_hash
        hash = params.compact.transform_keys! { |key| key.to_s.camelize }
        hash['idLanguage'] = hash.delete('languages')&.uniq!
        hash['idWant'] = id
        hash.delete_if { |_, value| value.nil? || (value.respond_to?(:empty?) && value.empty?) }

        add_product_id(hash)
        hash
      end

      def add_product_id(hash)
        return if hash['idWant']

        if @product.meta?
          hash[:idMetaproduct] = @product.id
        else
          hash[:idProduct] = @product.id
        end
      end

      def meta?
        product.meta?
      end

      def languages
        params[:languages]&.uniq!
      end

      def languages=(value)
        params[:languages] = value.uniq
      end

      class << self
        def from_hash(account, hash)
          product = create_product(account, hash)
          hash.transform_keys! { |key| key.underscore.to_sym }
          hash[:min_condition] &&= hash[:min_condition].to_sym
          hash[:languages] = hash[:id_language]
          WantslistItem.new(hash[:id_want], product, account, hash)
        end

        private

        def create_product(account, hash)
          if hash['type'] == 'metaproduct'
            MetaProduct.from_hash(account, hash['metaproduct'])
          else
            Product.from_hash(account, hash.slice(*%w[rarity expansionName countArticles countFoils])
                                           .merge!(hash['product']))
          end
        end
      end
    end
  end
end
