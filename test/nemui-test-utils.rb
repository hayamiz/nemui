
require 'nemui'

class Test::Unit::TestCase
  def assert_instance_array_of(klass, array, message=nil)
    array.each do |elem|
      assert_instance_of(klass, elem, message)
    end
  end

  def assert_boolean(actual, message=nil)
    if actual
      assert_same(true, actual, message)
    else
      assert_same(false, actual, message)
    end
  end

  def assert_included_in(expected_list, actual, message=nil)
    assert(expected_list.include?(actual), message)
  end
end
