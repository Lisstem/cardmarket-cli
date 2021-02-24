# frozen_string_literal: true

require_relative 'entity'
require_relative 'wantslist_item'

##
# see https://api.cardmarket.com/ws/documentation/API_2.0:Entities:Wantslist
class Wantslist < Entity
  PARAMS = [:name].freeze
  attr_(*PARAMS)
  attr_reader :id

  def initialize(name, id: nil)
    super()
    @params[:name] = name
    @id = id
    @items = []
    @deleted = []
  end

  def [](value)
    @items[value]
  end

  def items
    @items.dup
  end
  
  def add_item(item)
    @items << item unless item.nil?
    item
  end
  
  def delete_item(item)
    @deleted << @items.delete(item)
  end

  def self.from_hash(hash)
    list = Wantslist.new(hash['name'], id: hash['idWantsList'])
    hash['item'].each do |item|
      list.add_item(WantslistItem.from_hash(item))
    end
    list
  end
end
