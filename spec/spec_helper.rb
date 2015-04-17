$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'forcer'
require "rspec"
require "support/test_utility"

include Forcer::TestUtility

suppress_output_for_test
