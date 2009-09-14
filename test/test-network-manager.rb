
class NetworkManagerTest < Test::Unit::TestCase

  def setup
    @nm = NEMUI::NetworkManager.instance
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

  def test_properties
    assert_boolean(@nm[:wireless_enabled])
    assert_boolean(@nm[:wireless_hardware_enabled])
    assert_included_in([NEMUI::NetworkManager::NM_STATE_UNKNOWN,
                        NEMUI::NetworkManager::NM_STATE_ASLEEP,
                        NEMUI::NetworkManager::NM_STATE_CONNECTING,
                        NEMUI::NetworkManager::NM_STATE_CONNECTED,
                        NEMUI::NetworkManager::NM_STATE_DISCONNECTED],
                       @nm[:state])
    assert_instance_array_of(NEMUI::NetworkManagerSettings::Connection,
                             @nm[:active_connections])
  end
end
