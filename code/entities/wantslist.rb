# frozen_string_literal: true

require_relative 'deletable'
require_relative 'entity'
require_relative 'wantslist_item'
require_relative 'unique'

##
# see https://api.cardmarket.com/ws/documentation/API_2.0:Entities:Wantslist
class Wantslist < Entity
  extend Deletable
  
  PARAMS = [:name].freeze
  attr_(*PARAMS)
  list_attr :item
  attr_reader :id

  def initialize(id, name, account, params = {})
    super(account)
    @id = id
    @params = params.keep_if { |key, _| PARAMS.include? key }
    @params[:name] = name
    Wantslist.send(:add, self)
  end
  
  def path
    "wantslist/#{id}"
  end

  def get
    return unless id
    
    response = @account.get(path)
    hash = JSON.parse(response.response_body)['wantslist']

    @name = hash['name']
    clear
    @changed = false
    hash['item']&.each { |item| add_item(WantslistItem.from_hash(@account, item)) }
    self
  end

  def delete
    return unless id

    @account.delete(path, body: { action: 'deleteWantslist' })
  end

  class << self
    extend Deletable
    extend Unique
    list_attr :instance, default: false, suffix: false
    uniq_attr :instance, hash: false

    def get(account, load_all: true)
      response = account.get('wantslist')
      hash = JSON.parse(response.response_body)
      hash['wantslist']&.each do |item|
        list = from_hash(account, item)
        puts "#{list&.name}: #{load_all && list}"
        list.get if load_all && list
      end
      instances
    end

    def from_hash(account, hash)
      return nil unless hash['game']&.fetch('idGame') == 1

      list = Wantslist.new(hash['idWantsList'], hash['name'], account)
      hash['item']&.each { |item| list.add_item(WantslistItem.from_hash(account, item)) }
      list
    end
  end
end

