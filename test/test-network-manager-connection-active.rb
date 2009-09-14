
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
    @aconn = 
      if conns.empty?
        nil
      else
        conns.first
      end

  end

  # def teardown
  # end

  def test_properties
    return unless @aconn
    assert_instance_of(String, @aconn.service_name)
    assert(@aconn.devices)
    assert(@aconn.specific_object)
    assert_boolean(@aconn.default)
    active_klass = NEMUI::NetworkManager::Connection::Active
    assert(active_klass::NM_ACTIVE_CONNECTION_STATE_UNKNOWN == @aconn.state ||
           active_klass::NM_ACTIVE_CONNECTION_STATE_ACTIVATING == @aconn.state ||
           active_klass::NM_ACTIVE_CONNECTION_STATE_ACTIVATED == @aconn.state)
    assert_instance_of(NEMUI::NetworkManagerSettings::Connection, @aconn.connection)
    @aconn.devices.each do |dev| 
      assert_kind_of(NEMUI::NetworkManager::Device, dev)
    end
  end

  def test_state
    return unless @aconn
  end
end
