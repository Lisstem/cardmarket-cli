# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'cardmarket_cli'

require 'minitest/autorun'
require 'minitest/reporters'
require 'mocha/minitest'

require 'cardmarket_test'
require 'api_test'
require 'assertions'

Minitest::Reporters.use!

# Disable logging
CardmarketCLI::Logging.disable
