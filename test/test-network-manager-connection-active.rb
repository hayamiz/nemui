
class NetworkManagerConnectionActiveTest < Test::Unit::TestCase
  def setup
    @nm = NEMUI::NetworkManager.instance

    # waiting connection
    if @nm.state == NEMUI::NetworkManager::NM_STATE_CONNECTING
      now = Time.now
      while Time.now - now < 5 &&
          @nm.state == NEMUI::NetworkManager::NM_STATE_CONNECTING
        # waiting
        sleep 0.1
      end
    end

    conns = @nm.active_connections
    @conn = 
      if conns.empty?
        nil
      else
        conns.first
      end

  end

  # def teardown
  # end

  def test_properties
    return unless @conn
    assert_instance_of(String, @conn.service_name)
    assert(@conn.devices)
    assert(@conn.specific_object)
    assert_boolean(@conn.default)
    assert(NEMUI::NetworkManager::Connection::Active::NM_ACTIVE_CONNECTION_STATE_UNKNOWN == @conn.state ||
           NEMUI::NetworkManager::Connection::Active::NM_ACTIVE_CONNECTION_STATE_ACTIVATING == @conn.state ||
           NEMUI::NetworkManager::Connection::Active::NM_ACTIVE_CONNECTION_STATE_ACTIVATED == @conn.state)
    assert_instance_of(NEMUI::NetworkManagerSettings::Connection, @conn.connection)
    @conn.devices.each do |dev| 
      assert_kind_of(NEMUI::NetworkManager::Device, dev)
    end
  end

  def test_state
    return unless @conn
  end
end
