# frozen_string_literal: true

require_relative 'unique'
require_relative 'entity'
require_relative 'product'

##
# See https://api.cardmarket.com/ws/documentation/API_2.0:Entities:Metaproduct
class MetaProduct < Entity
  PARAMS = %i[en_name loc_name from_price products].freeze
  attr_r(*(PARAMS - [:products]))
  attr_reader :id

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
    @params[:products].dup
  end

  private

  def merge_params(params)
    @params.merge!(params.select { |key, _| PARAMS.include? key })
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
  end
end
