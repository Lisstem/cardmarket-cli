# frozen_string_literal: true

require_relative 'unique'
require_relative 'entity'
require_relative 'meta_product'

##
# See https://api.cardmarket.com/ws/documentation/API_2.0:Entities:Product
class Product < Entity
  PARAMS = %i[en_name loc_name from_price meta_product expansion_name rarity count_articles count_foils].freeze
  attr_r(*PARAMS)
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

  private

  def merge_params(params)
    @params.merge!(params.select { |key, _| PARAMS.include? key })
    @params[:rarity] = @params[:rarity].to_s.downcase!.to_sym
    self
  end

  class << self
    extend Unique
    uniq_attr :instance

    private :new
    
    def from_hash(account, hash)
      hash.transform_keys! { |key| key.underscore.to_sym }
      hash[:meta_product] = MetaProduct.create(hash.delete(:id_metaproduct), account)
      Product.create(hash[:id_product], account, hash)
    end
    
    def create(id, account, params = {})
      self[id]&.send(:merge_params, params) || new(id, account, params)
    end
  end
end
