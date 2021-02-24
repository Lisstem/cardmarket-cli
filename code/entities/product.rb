# frozen_string_literal: true

require_relative 'unique'
require_relative 'entity'

##
# See https://api.cardmarket.com/ws/documentation/API_2.0:Entities:Product
class Product < Entity
  attr_reader :id

  def initialize(id, account, params = {})
    super(account)
    @id = id
    Product.send(:add, self)
  end

  def meta?
    false
  end
  
  class << self
    extend Unique
    uniq_attr :instance
  end
end
