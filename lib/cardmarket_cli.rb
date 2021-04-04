# frozen_string_literal: true

require 'cardmarket_cli/version'
require 'cardmarket_cli/account'
require 'cardmarket_cli/logging'
require 'cardmarket_cli/entities/deletable'
require 'cardmarket_cli/entities/entity'
require 'cardmarket_cli/entities/changeable'
require 'cardmarket_cli/entities/meta_product'
require 'cardmarket_cli/entities/product'
require 'cardmarket_cli/entities/wantslist'
require 'cardmarket_cli/entities/wantslist_item'

##
# Namespace for this Gem
module CardmarketCLI
  class Error < StandardError; end
  # Your code goes here...
  # Enable logging with default logger
  Logging.enable
end
