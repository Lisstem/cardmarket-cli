# frozen_string_literal: true

##
# Base for all entites in the API
class Entity
  def initialize
    @changed = false
    @params = {}
  end

  def changed?
    @changed
  end
  
  class << self
    protected

    def attr_(*symbols)
      symbols.each do |symbol|
        define_method "#{symbol}=" do |val|
          @params[symbol] = val
          @changed = true
        end

        define_method symbol do
          @params[symbol]
        end
      end
    end
  end 
end
