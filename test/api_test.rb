# frozen_string_literal: true

require 'typhoeus'
require 'cardmarket_test'
require 'yaml'

module CardmarketCLI
  ##
  # Tests which access the Cardmarket API
  class APITest < CardmarketTest
    def setup
      Typhoeus::Expectation.clear
    end

    def stub_url(url, response)
      response = APITest.responses(response).dup unless response.respond_to? :options
      response.options[:effective_url] = url
      Typhoeus.stub(url).and_return(response)
    end

    class << self
      def load_responses
        @responses = {}

        Dir.glob("#{__dir__}/typhoeus_responses/*.yaml").each do |response|
          name = File.basename(response).split('.')[0].to_sym
          @responses[name] = YAML.load_file(response)
        end
      end

      def responses(name)
        @responses[name]
      end
    end
  end
end

CardmarketCLI::APITest.load_responses
