# frozen_string_literal: true

require_relative 'unique'
require_relative 'entity'
require_relative 'meta_product'

##
# See https://api.cardmarket.com/ws/documentation/API_2.0:Entities:Product
class Product < Entity
  PARAMS = %i[en_name loc_name meta_product expansion_name rarity count_articles count_foils price_guide].freeze
  PATH_BASE = 'products'
  attr_r(*(PARAMS - [:price_guide]))
  attr_reader :id

  def initialize(id, account, params = {})
    super(account)
    @id = id
    @params = {}
    merge_params(params)
    Product.send(:add, self)
  end

  def meta?
    false
  end

  def read
    LOGGER.debug("Reading Product #{en_name}(#{id})")
    response = @account.get("#{PATH_BASE}/#{id}")
    hash = JSON.parse(response.response_body)['product']
    hash['expansion_name'] ||= hash['expansion']&.fetch('enName')
    Product.from_hash(@account, hash)
  end

  def price_guide
    @params[:price_guide].dup
  end

  private

  def merge_params(params)
    params[:price_guide]&.transform_keys! { |key| key.to_s.underscore.to_sym }&.delete(nil)
    @params.merge!(params.slice(*PARAMS))
    @params[:rarity] = @params[:rarity]&.to_s&.downcase!&.to_sym
    @updated_at = Time.now
    self
  end

  class << self
    extend Unique
    uniq_attr :instance

    private :new

    def from_hash(account, hash)
      hash.transform_keys! { |key| key.underscore.to_sym }
      hash[:meta_product] = MetaProduct.create(hash.delete(:id_metaproduct), account)
      product = Product.create(hash[:id_product], account, hash)
      hash[:meta_product]&.send(:merge_params, { products: [product] })
      product
    end

    def create(id, account, params = {})
      self[id]&.send(:merge_params, params) || new(id, account, params)
    end

    def search(account, search_string, exact: false)
      start = 0
      products = []
      loop do
        single_search(account, search_string, products, start, exact: exact)
        break unless products.count == start += 100
      end
      products
    end

    private

    def single_search(account, search_string, array, start, exact: false)
      response = account.get("#{PATH_BASE}/find", params: { search: search_string, exact: exact, start: start,
                                                            maxResults: 100, idGame: 1, idLanguage: 1 })
      JSON.parse(response.response_body)['product']&.each do |product|
        array << from_hash(account, product)
      end
      array
    end
  end
end
