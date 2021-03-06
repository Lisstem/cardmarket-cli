# frozen_string_literal: true

require_relative 'unique'
require_relative 'entity'
require_relative 'product'

##
# See https://api.cardmarket.com/ws/documentation/API_2.0:Entities:Metaproduct
class MetaProduct < Entity
  PARAMS = %i[en_name loc_name products].freeze
  PATH_BASE = 'metaproducts'
  attr_r(*(PARAMS - [:products]))
  attr_reader :id, :updated_at

  def initialize(id, account, params = {})
    super(account)
    @id = id
    @params = {}
    merge_params(params)
    MetaProduct.send(:add, self)
  end

  def meta?
    true
  end

  def products
    read unless @params[:products]
    @params[:products].dup
  end

  def read
    LOGGER.debug("Reading Metaproduct #{en_name}(#{id})")
    response = @account.get("#{PATH_BASE}/#{id}")
    hash = JSON.parse(response.response_body)
    hash['metaproduct']&.store('product', hash['product'])
    MetaProduct.from_hash(@account, hash['metaproduct'])
  end

  private

  def merge_params(params)
    @params[:products] ||= []
    params[:products] = @params[:products].union(params[:products] || [])
    @params.merge!(params.slice(*PARAMS))
    @updated_at = Time.now
    self
  end

  class << self
    extend Unique
    uniq_attr :instance

    private :new

    def from_hash(account, hash)
      hash.transform_keys! { |key| key.underscore.to_sym }
      hash[:products] = []
      hash.delete(:product)&.each do |product|
        hash[:products] << Product.from_hash(account, product)
      end
      MetaProduct.create(hash[:id_metaproduct], account, hash)
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
      JSON.parse(response.response_body)['metaproduct']&.each do |product|
        array << from_hash(account, product)
      end
      array
    end
  end
end
