
require 'singleton'


module NEMUI
  class NetworkManager < DBusObject
    interface Interface::NETWORK_MANAGER

    NM_STATE_UNKNOWN = 0
    NM_STATE_ASLEEP = 1
    NM_STATE_CONNECTING = 2
    NM_STATE_CONNECTED = 3
    NM_STATE_DISCONNECTED = 4

    PATH = "/org/freedesktop/NetworkManager"

    def self.instance
      self.create(PATH)
    end
    
    def call(method, *args)
      @default_iface_obj.__send__(method, *args)
    end

    def get_devices()
      devices = @default_iface_obj.GetDevices()[0].map do |dev_path|
        begin
          Device.create(dev_path)
        rescue NotImplementedDevice
          nil
        end
      end
    end

    def active_connections()
      conns = self[:ActiveConnections]
      conns.map do |conn_path|
        Connection::Active.create(conn_path)
      end
    end

    def wake(wak = true)
      @default_iface_obj.Sleep(!wak)
      nil
    end

    def sleep(slp = true)
      self.wake(!slp)
      nil
    end
    
    class Device < DBusObject
      class NotImplementedDevice < Exception; end
      interface Interface::DEVICE
      
      def self.create(path)
        self.__create__(path) do |obj|
          if obj.has_iface?(Interface::WIRED)
            Wired.create(path)
          elsif obj.has_iface?(Interface::WIRELESS)
            Wireless.create(path)
          else
            raise NotImplementedDevice.new(path)
          end
        end
      end

      class Wired < Device
        interface Interface::WIRED
      end

      class Wireless < Device
        interface Interface::WIRELESS
      end
    end

    module Connection
      class Active < DBusObject
        interface Interface::CONNECTION_ACTIVE

        NM_ACTIVE_CONNECTION_STATE_UNKNOWN = 0
        NM_ACTIVE_CONNECTION_STATE_ACTIVATING = 1
        NM_ACTIVE_CONNECTION_STATE_ACTIVATED = 2
      end
    end
  end
end
