
class StringExtTest < Test::Unit::TestCase

  def test_camelize
    assert_equal("NetworkManager",
                 "network_manager".camelize)
  end

  def test_decamelize
    assert_equal("network_manager",
                 "NetworkManager".decamelize)
  end
end
