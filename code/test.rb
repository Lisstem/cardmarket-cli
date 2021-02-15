require 'faraday'
require 'oauth'
require 'typhoeus'
require 'oauth/request_proxy/typhoeus_request'
require 'json'

uri = '/ws/v2.0/output.json/account'
secrets = JSON.parse(File.read 'secrets.json')
puts secrets
oauth_consumer = OAuth::Consumer.new(secrets["APP_TOKEN"], secrets["APP_SECRET"], site: "https://api.cardmarket.com", debug: true)
access_token = OAuth::AccessToken.new(oauth_consumer, secrets["ACCESS_TOKEN"], secrets["ACCESS_TOKEN_SECRET"])
oauth_params = {:consumer => oauth_consumer, :token => access_token}
req = Typhoeus::Request.new(oauth_consumer.site + uri, method: :get)
oauth_helper = OAuth::Client::Helper.new(req, oauth_params.merge(request_uri: oauth_consumer.site + uri))
req.options[:headers].merge!({"Authorization" => oauth_helper.header + ", realm=#{(oauth_consumer.site + uri).inspect}"}) # Signs the request
puts req.run
puts req.response.body



