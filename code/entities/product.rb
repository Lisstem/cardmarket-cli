# frozen_string_literal: true

require_relative 'unique'

##
# See https://api.cardmarket.com/ws/documentation/API_2.0:Entities:Product
class Product
  extend Unique

  def initialize(id)
    @id = id
  end

  def meta?
    false
  end
end
