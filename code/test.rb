# frozen_string_literal: true

require 'json'
require 'yaml'
require_relative 'account'
require_relative 'entities/wantslist'
require_relative 'util/logger'

config = JSON.parse(File.read('config.json'))
config['TEST'] = true if config['TEST'].nil?
LOGGER.level = config['LOGGING_LEVEL'] || :info
LOGGER.level = :info
account = Account.new(config['APP_TOKEN'], config['APP_SECRET'], config['ACCESS_TOKEN'],
                      config['ACCESS_TOKEN_SECRET'], test: config['TEST'])
# puts list.to_yaml
# puts account.get('account').response_body.to_yaml
# item = list.items[0]
# item.count = 4
# item.min_condition = :NM
# item.is_playset = true
# item.mail_alert = true
# item.from_price = 5
# item.languages << 1
# puts list.update.to_yaml
# puts MetaProduct.search(account, 'tarmogoyf').to_yaml
# product.read
# puts product.to_yaml
# puts list.update.to_yaml
# puts JSON.parse(request.response_body).to_yaml
# puts account.get(Wantslist::PATH_BASE).to_yaml
