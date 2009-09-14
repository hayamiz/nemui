
class NetworkManagerTest < Test::Unit::TestCase

  def setup
    @nm = NEMUI::NetworkManager.instance
  end

  def test_sleep
    begin
      @nm.sleep
    rescue DBus::Error => err
      unless err.message =~ /Already asleep/
        raise err
      end
    end
    assert_equal(NEMUI::NetworkManager::NM_STATE_ASLEEP, @nm.state)
    @nm.wake
    assert(NEMUI::NetworkManager::NM_STATE_CONNECTING == @nm.state ||
           NEMUI::NetworkManager::NM_STATE_CONNECTED == @nm.state  ||
           NEMUI::NetworkManager::NM_STATE_DISCONNECTED == @nm.state)
  end

  def teardown
    begin
      @nm.wake
    rescue DBus::Error => err
      unless err.message =~ /Already awake/
        raise err
      end
    end
  end
end
