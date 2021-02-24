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
# response = account.get('account')
# response = account.post('wantslist', body: XmlSimple.xml_out({ wantslist: { name: 'test', idGame: 1 } },
#                                                             RootName: 'request', XmlDeclaration: true))
# puts response.inspect
# puts JSON.parse(response.response_body)['wantslist']
list = Wantslist.new(2_112_277, nil, account)
list.read
puts list.to_yaml
