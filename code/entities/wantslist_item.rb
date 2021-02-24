# frozen_string_literal: true

require_relative 'entity'
require_relative 'product'
require_relative 'meta_product'

##
# see https://api.cardmarket.com/ws/documentation/API_2.0:Wantslist_Item
class WantslistItem < Entity
  PARAMS = %i[count min_condition wish_price mail_alert languages foil altered playset signed first_edition].freeze
  attr_(*PARAMS)
  attr_reader :id

  def initialize(product, id: nil,
                 params: { count: 1, min_condition: :po, wish_price: 0.0, mail_alert: false, languages: [1], foil: nil,
                           altered: nil, playset: nil, signed: nil, first_edition: nil })
    super()
    @product = product
    @params = params.keep_if { |key, _| PARAMS.include? key }
    @changed = false
    @id = id
  end

  def to_xml_hash
    hash = { idWant: id, minCondition: min_condition.to_s.upcase!, wishPrice: wish_price, mailAlert: mail_alert,
             idLanguage: languages, isFoil: foil, isAltered: altered, isPlayset: playset, isSigned: signed,
             isFirstEd: first_edition }
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

  def self.from_hash(hash)
    product = hash['type'] == 'metaproduct' ? MetaProduct[hash['idMetaproduct']] : Product[hash['idProduct']]
    min_condition = hash['minCondition'].nil? ? nil : hash['minCondition'].downcase!.to_sym
    WantslistItem.new(product,
                      id: hash['idWant'],
                      params: { count: hash['count'], min_condition: min_condition, wish_price: hash['wish_price'],
                               mail_alert: hash['mailAlert'], languages: hash['idLanguages'], foil: hash['isFoil'],
                               altered: hash['isAltered'], playset: hash['isPlayerset'], signed: hash['isSigned'],
                               first_edition: hash['isFirstEd']})
  end
end
