# frozen_string_literal: true

require 'oauth'
require 'typhoeus'
require 'oauth/request_proxy/typhoeus_request'
require 'xmlsimple'
require 'cgi'
require 'cardmarket_cli/logger'
require 'json'

module CardmarketCLI
  ##
  #
  class Account
    attr_reader :request_limit, :request_count

    def initialize(app_token, app_secret, access_token, access_token_secret, options = {})
      options[:site] ||= options[:test] ? 'https://sandbox.cardmarket.com' : 'https://api.cardmarket.com'
      @oauth_consumer = OAuth::Consumer.new(app_token, app_secret, site: options[:site])
      @access_token = OAuth::AccessToken.new(@oauth_consumer, access_token, access_token_secret)
    end

    def get(path, body: nil, format: :json, params: {})
      request(path, :get, body: body, format: format, params: params)
    end

    def put(path, body: nil, format: :json, params: {})
      request(path, :put, body: body, format: format, params: params)
    end

    def post(path, body: nil, format: :json, params: {})
      request(path, :post, body: body, format: format, params: params)
    end

    def delete(path, body: nil, format: :json, params: {})
      request(path, :delete, body: body, format: format, params: params)
    end

    def request(path, method, body: nil, format: :json, params: {})
      uri = make_uri(path, format: format, params: params)
      req = Typhoeus::Request.new(uri, method: method, body: make_body(body))
      oauth_helper = OAuth::Client::Helper.new(req, consumer: @oauth_consumer, token: @access_token, request_uri: uri)
      req.options[:headers].merge!(
        { 'Authorization' => oauth_helper.header + ", realm=#{make_uri(path, format: format).inspect}" }
      )
      LOGGER.info log_request(method, uri, body)
      run_req(req)
    end

    def make_uri(path, format: :json, params: {})
      raise "Unknown format #{format}" unless %i[json xml].include?(format)

      params = "#{'?' unless params.empty?}#{params.to_a.map { |k, v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }
                                              .join('&')}"
      "#{@oauth_consumer.site}/ws/v2.0/output.#{format}/#{path}#{params}"
    end

    def make_body(body)
      if body.respond_to? :each
        body = XmlSimple.xml_out(body, RootName: 'request', XmlDeclaration: '<?xml version="1.0" encoding="UTF-8" ?>',
                                       SuppressEmpty: nil, NoAttr: true)
      end
      body
    end

    private

    def run_req(req)
      response = req.run
      @request_count = get_from_header(response, /X-Request-Limit-Count: \d+/).to_i
      @request_limit = get_from_header(response, /X-Request-Limit-Max: \d+/).to_i
      LOGGER.info("#{response.response_code} (#{response.return_code}) (Limit: "\
                  "#{request_count || '?'}/#{request_limit || '?'})")
      LOGGER.debug { JSON.parse(response.response_body).to_yaml }
      response
    end

    def get_from_header(response, regex)
      match = response.response_headers.match(regex)
      match&.size&.positive? ? match[0].split(':')&.fetch(1) : nil
    end

    def log_request(method, uri, body)
      LOGGER.info("#{method.to_s.capitalize}: #{uri.inspect}")
      LOGGER.debug { body.to_yaml }
    end
  end
end
