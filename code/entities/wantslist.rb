# frozen_string_literal: true

require_relative 'deletable'
require_relative 'entity'
require_relative 'wantslist_item'
require_relative 'unique'
require_relative '../util/logger'

##
# see https://api.cardmarket.com/ws/documentation/API_2.0:Entities:Wantslist
class Wantslist < Entity
  extend Deletable

  PARAMS = %i[name].freeze
  PATH_BASE = 'wantslist'
  attr_(*PARAMS)
  list_attr :item
  attr_reader :id

  def initialize(id, name, account, params = {})
    super(account)
    @id = id
    @params = params.slice(*PARAMS)
    @params[:name] = name
    Wantslist.send(:add, self)
  end

  def path
    "#{PATH_BASE}/#{id}"
  end

  def read
    LOGGER.debug("Reading wantslist #{name}(#{id})")
    return unless id

    response = @account.get(path)
    hash = JSON.parse(response.response_body)['wantslist']

    @name = hash['name']
    clear
    @changed = false
    hash['item']&.each { |item| add_item(WantslistItem.from_hash(@account, item)) }
    response
  end

  def delete
    LOGGER.debug("Deleting wantslist #{name}(#{id})")
    return unless id

    @account.delete(path, body: { action: 'deleteWantslist' })
  end

  def update
    LOGGER.debug("Updating wantslist #{name}(#{id})")
    responses = {}
    responses[:create] = create unless id
    responses[:update] = patch if changed?
    patch_items(responses)
    responses.compact!
  end

  private
  
  def patch_items(responses)
    responses[:create_items] = create_items
    responses[:update_items] = update_items
    responses[:delete_items] = delete_items
    responses
  end

  def create
    response = @account.post(PATH_BASE, body: { wantslist: { name: name, idGame: 1 } })
    @id = JSON.parse(response)['wantslist']&.fetch(0)&.fetch('idWantsList')
    response
  end

  def patch
    @account.put(path, body: { action: 'editWantslist', name: name })
  end

  def create_items
    new_items = @items.reject(&:id)
    return nil if new_items.empty?

    @account.put(path, body: { action: 'addItem',
                                product: new_items.reject(&:meta?).map!(&:to_xml_hash),
                                metaproduct: new_items.select(&:meta?).map!(&:to_xml_hash) })
  end

  def update_items
    changed_items = @items.select(&:changed?)
    return nil if changed_items.empty?

    @account.put(path, body: { action: 'editItem', want: changed_items.map!(&:to_xml_hash) })
  end

  def delete_items
    return nil if deleted_items.empty?

    @account.put(path, body: { action: 'deleteItem', want: @deleted_items.map { |item| { idWant: item.id } } })
  end

  class << self
    extend Deletable
    extend Unique
    list_attr :instance, default: false, suffix: false
    uniq_attr :instance, hash: false

    def read(account, eager: true)
      LOGGER.debug('Reading wantslists')
      response = account.get(PATH_BASE)
      hash = JSON.parse(response.response_body)
      hash['wantslist']&.each do |item|
        list = from_hash(account, item)
        list.read if eager && list
      end
      instances
    end

    def update
      instances.each(&:update)
      deleted_instances.each(&:delete)
    end

    def create(*args)
      new(*args)
    end

    def from_hash(account, hash)
      return nil unless hash['game']&.fetch('idGame') == 1

      list = Wantslist.new(hash['idWantsList'], hash['name'], account)
      hash['item']&.each { |item| list.add_item(WantslistItem.from_hash(account, item)) }
      list
    end
  end
end

