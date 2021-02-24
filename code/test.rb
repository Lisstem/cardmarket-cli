# frozen_string_literal: true

require 'json'
require 'yaml'
require 'xmlsimple'
require_relative 'card_market'
require_relative 'entities/wantslist'

secrets = JSON.parse(File.read('secrets.json'))
account = CardMarket.new(secrets['APP_TOKEN'], secrets['APP_SECRET'], secrets['ACCESS_TOKEN'],
                         secrets['ACCESS_TOKEN_SECRET'])
# response = account.get('account')
response = account.get('wantslist/11685378')
# response = account.post('wantslist', body: XmlSimple.xml_out({ wantslist: { name: 'test', idGame: 1 } },
#                                                             RootName: 'request', XmlDeclaration: true))
# puts response.inspect
puts JSON.parse(response.response_body)['wantslist']
puts Wantslist.from_hash((JSON.parse(response.response_body)['wantslist'])).to_yaml




