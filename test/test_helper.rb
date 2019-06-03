$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'minitest/autorun'
require 'minitest/reporters'

$VERBOSE=nil

Minitest::RelativePosition::TEST_SIZE = 75
Minitest::Reporters.use! [
  Minitest::Reporters::SpecReporter.new
]
