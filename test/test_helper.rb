require 'minitest/autorun'
require 'mutant/minitest/coverage'
require 'issue'

def assert_events(actual, expected)
  to_compare = ->(ev) { ev.to_h.slice(:type, :data) }
  assert_equal actual.map(&to_compare) , expected.map(&to_compare)
end