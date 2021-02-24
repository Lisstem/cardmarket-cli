# frozen_string_literal: true

require 'json'
require 'yaml'
require 'xmlsimple'
require_relative 'account'
require_relative 'entities/wantslist'

secrets = JSON.parse(File.read('secrets.json'))
account = Account.new(secrets['APP_TOKEN'], secrets['APP_SECRET'], secrets['ACCESS_TOKEN'],
                      secrets['ACCESS_TOKEN_SECRET'])
# response = account.get('account')
# response = account.post('wantslist', body: XmlSimple.xml_out({ wantslist: { name: 'test', idGame: 1 } },
#                                                             RootName: 'request', XmlDeclaration: true))
# puts response.inspect
# puts JSON.parse(response.response_body)['wantslist']
puts Wantslist.get(account).to_yaml
