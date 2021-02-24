# frozen_string_literal: true

require_relative 'entity'
require_relative 'product'
require_relative 'meta_product'
require_relative '../util/string'

##
# see https://api.cardmarket.com/ws/documentation/API_2.0:Wantslist_Item
class WantslistItem < Entity
  PARAMS = %i[count min_condition wish_price mail_alert languages is_foil is_altered is_playset is_signed
              is_first_ed].freeze
  attr_(*PARAMS)
  attr_reader :id, :product

  def initialize(id, product, account, params = {})
    params = { count: 1, min_condition: :PO, wish_price: 0.0, mail_alert: false, languages: [1], is_foil: nil,
               is_altered: nil, is_playset: nil, is_signed: nil, is_first_ed: nil }.merge!(params)
    super(account)
    @product = product
    @params = params.select { |key, _| PARAMS.include? key }
    @changed = false
    @id = id
  end

  def to_xml_hash
    hash = params.transform_keys { |key| key.to_s.camelize }
    hash['idLanguage'] = hash.delete('languages')
    hash['idWant'] = id
    hash.delete_if { |_, value| value.nil? || value.empty? }

    add_product_id(hash) if id.nil?
    hash
  end

  def add_product_id(hash)
    if @product.meta?
      hash[:idMetaproduct] = @product.id
    else
      hash[:idProduct] = @product.id
    end
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
        MetaProduct.from_hash(account, { 'fromPrice' => hash['fromPrice'] }.merge!(hash['metaproduct']))
      else
        Product.from_hash(account, hash.select do |key, _|
          %w[rarity expansionName countArticles countFoils fromPrice].include?(key)
        end.merge!(hash['product'] || {}))
      end
    end
  end
end
