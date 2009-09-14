
module NEMUI
  class NetworkManagerSettings < DBusObject
    class Connection < DBusObject
      interface "org.freedesktop.NetworkManager"
    end
  end
end
