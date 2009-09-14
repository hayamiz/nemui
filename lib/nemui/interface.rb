

module NEMUI
  module Interface
    NETWORK_MANAGER = "org.freedesktop.NetworkManager"
    DEVICE = "org.freedesktop.NetworkManager.Device"
    WIRED = "org.freedesktop.NetworkManager.Device.Wired"
    WIRELESS = "org.freedesktop.NetworkManager.Device.Wireless"
    PROPERTIES = "org.freedesktop.DBus.Properties"
    CONNECTION_ACTIVE = "org.freedesktop.NetworkManager.Connection.Active"
  end

  class InterfaceMismatchError < Exception; end
end
