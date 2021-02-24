# frozen_string_literal: true

require 'json'
require 'yaml'
require_relative 'account'
require_relative 'entities/wantslist'
require_relative 'util/logger'

config = JSON.parse(File.read('config.json'))
LOGGER.level = config['LOGGING_LEVEL'] || :info
account = Account.new(config['APP_TOKEN'], config['APP_SECRET'], config['ACCESS_TOKEN'],
                      config['ACCESS_TOKEN_SECRET'])
# list = Wantslist.new(2_112_277, nil, account)
# list.read
# puts list.to_yaml
puts account.get('products/find', params: { search: 'Springleaf Drum', exact: true, idGame: 1, idLanguage: 1 }).to_yaml
# puts account.get(Wantslist::PATH_BASE).to_yaml
