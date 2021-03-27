# frozen_string_literal: true

# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
# directories %w(app lib config test spec features) \
#  .select{|d| Dir.exist?(d) ? d : UI.warning("Directory #{d} does not exist")}

## Note: if you are using the `directories` clause above and you are not
## watching the project directory ('.'), then you will want to move
## the Guardfile to a watched dir and symlink it back, e.g.
#
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
#
# and, you'll have to watch "config/Guardfile" instead of "Guardfile"
API_TESTS = %w[meta_product product wantslist wantslist_item].freeze

guard :minitest do
  # with Minitest::Unit
  watch(%r{^test/(.*)/?(.*)_test\.rb$})
  watch(%r{^lib/cardmarket_cli/(.*/)?([^/]+)\.rb$}) do |m|
    %W[test/unit/#{m[1]}#{m[2]}_test.rb]
  end
  watch(%r{^test/assertions.rb$})        { 'test' }
  watch(%r{^test/test_helper\.rb$})      { 'test' }
  watch(%r{^test/cardmarket_test.rb$})   { 'test' }
  watch(%r{^test/api_test.rb$}) do
    API_TESTS.map { |m| "test/unit/entities/#{m}_test.rb" } << 'test/account_test.rb'
  end

  # with Minitest::Spec
  # watch(%r{^spec/(.*)_spec\.rb$})
  # watch(%r{^lib/(.+)\.rb$})         { |m| "spec/#{m[1]}_spec.rb" }
  # watch(%r{^spec/spec_helper\.rb$}) { 'spec' }
end
