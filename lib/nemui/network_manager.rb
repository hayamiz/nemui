
require 'singleton'


module NEMUI
  class NetworkManager
    include Singleton
    include Properties

    NM_STATE_UNKNOWN = 0
    NM_STATE_ASLEEP = 1
    NM_STATE_CONNECTING = 2
    NM_STATE_CONNECTED = 3
    NM_STATE_DISCONNECTED = 4

    PATH = "/org/freedesktop/NetworkManager"
    
    def initialize
      bus = DBus::SystemBus.instance
      service = bus.service(NM_SERVICE)
      @default_iface = Interface::NETWORK_MANAGER
      @proxy_obj = service.object(PATH)
      @proxy_obj.introspect
      
      @nm_iface = @proxy_obj[Interface::NETWORK_MANAGER]
    end

    def call(method, *args)
      @nm_iface.__send__(method, *args)
    end

    def get_devices()
      devices = @nm_iface.GetDevices()[0].map do |dev_path|
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
      @nm_iface.Sleep(!wak)
      nil
    end

    def sleep(slp = true)
      self.wake(!slp)
      nil
    end
    
    class Device
      class NotImplementedDevice < Exception; end
      
      def self.create(path)
        bus = DBus::SystemBus.instance
        service = bus.service(NM_SERVICE)
        obj = service.object(path)
        obj.introspect
        
        if obj.has_iface?(Interface::WIRED)
          Wired.new(obj)
        elsif obj.has_iface?(Interface::WIRELESS)
          Wireless.new(obj)
        else
          raise NotImplementedDevice.new(path)
        end
      end

      class Wired
        include Properties

        def initialize(obj)
          @proxy_obj = obj
          @default_iface = Interface::WIRED
          @wired_iface = @proxy_obj[Interface::NETWORK_MANAGER]
        end
      end

      class Wireless
        include Properties

        def initialize(obj)
          @proxy_obj = obj
          @default_iface = Interface::WIRELESS
          @wired_iface = @proxy_obj[Interface::NETWORK_MANAGER]
        end
      end
    end

    module Connection
      class Active
        include Properties

        NM_ACTIVE_CONNECTION_STATE_UNKNOWN = 0
        NM_ACTIVE_CONNECTION_STATE_ACTIVATING = 1
        NM_ACTIVE_CONNECTION_STATE_ACTIVATED = 2
      
        def self.create(path)
          bus = DBus::SystemBus.instance
          service = bus.service(NM_SERVICE)
          obj = service.object(path)
          obj.introspect

          unless obj.has_iface?(Interface::CONNECTION_ACTIVE)
            raise InterfaceMismatchError.new(Interface::CONNECTION_ACTIVE)
          end

          self.new(obj)
        end
        
        private
        def initialize(obj)
          @proxy_obj = obj
          @default_iface = Interface::CONNECTION_ACTIVE
          @conn_act_iface = @proxy_obj[Interface::CONNECTION_ACTIVE]
        end
      end
    end
  end
end
