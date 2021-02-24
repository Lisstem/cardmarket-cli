# frozen_string_literal: true

require 'oauth'
require 'typhoeus'
require 'oauth/request_proxy/typhoeus_request'
require 'xmlsimple'
require_relative 'util/logger'

##
#
class Account
  attr_reader :request_limit, :request_count

  def initialize(app_token, app_secret, access_token, access_token_secret)
    @oauth_consumer = OAuth::Consumer.new(app_token, app_secret, site: 'https://api.cardmarket.com')
    @access_token = OAuth::AccessToken.new(@oauth_consumer, access_token, access_token_secret)
  end

  def get(path, body: nil, format: :json)
    request(path, :get, body: body, format: format)
  end

  def post(path, body: nil, format: :json)
    request(path, :post, body: body, format: format)
  end

  def delete(path, body: nil, format: :json)
    request(path, :delete, body: body, format: format)
  end

  def request(path, method, body: nil, format: :json)
    uri = make_uri(path, format: format)
    req = Typhoeus::Request.new(uri, method: method, body: make_body(body))
    oauth_helper = OAuth::Client::Helper.new(req, consumer: @oauth_consumer, token: @access_token, request_uri: uri)
    req.options[:headers].merge!({ 'Authorization' => oauth_helper.header + ", realm=#{uri.inspect}" })
    LOGGER.debug("#{method.to_s.capitalize}: #{uri.inspect}")
    run_req(req)
  end

  def make_uri(path, format: :json)
    raise "Unknown format #{format}" unless %i[json xml].include?(format)

    "#{@oauth_consumer.site}/ws/v2.0/output.#{format}/#{path}"
  end

  def make_body(body)
    body = XmlSimple.xml_out(body, RootName: 'request', XmlDeclaration: true) if body.respond_to? :each
    body
  end

  private

  def run_req(req)
    response = req.run
    @request_count = response.response_headers.match(/X-Request-Limit-Count: \d+/)[0].split(':')[1].to_i
    @request_limit = response.response_headers.match(/X-Request-Limit-Max: \d+/)[0].split(':')[1].to_i
    LOGGER.debug("#{response.response_code} (#{response.return_code}) (Limit: #{request_count}/#{request_limit})")
    response
  end
end
