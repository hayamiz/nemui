#!/usr/bin/env ruby

require 'singleton'
require 'rubygems'
require 'dbus'

class InterfaceMismatchError < Exception; end

class String
  def camelize
    self.gsub(/(?:_|^)([a-z])/) {|m|
      $~[1].upcase
    }
  end
  
  def decamelize
    self.gsub(/^([A-Z])/) {|m|
      m.downcase
    }.gsub(/([A-Z])/) {|m|
      "_" + m.downcase
    }
  end
end

module NEMUI
  NM_SERVICE = "org.freedesktop.NetworkManager"
  
  module Interface
    NETWORK_MANAGER = "org.freedesktop.NetworkManager"
    DEVICE = "org.freedesktop.NetworkManager.Device"
    WIRED = "org.freedesktop.NetworkManager.Device.Wired"
    WIRELESS = "org.freedesktop.NetworkManager.Device.Wireless"
    PROPERTIES = "org.freedesktop.DBus.Properties"
  end

  # @proxy_obj, @default_iface required
  module Properties
    def properties
      if @proxy_obj.has_iface?(Interface::PROPERTIES)
        @prop_iface = @proxy_obj[Interface::PROPERTIES]
      else
        raise InterfaceMismatchError.new(Interface::PROPERTIES)
      end
    end

    def [](prop_name)
      prop_name = prop_name.to_s.camelize
      self.properties.Get(@default_iface, prop_name)[0]
    end
    
    def []=(prop_name, value)
      prop_name = prop_name.to_s.camelize
      self.properties.Set(@default_iface, prop_name, value)
    end
    
    def method_missing(method_id, *args)
      method_id = method_id.to_s
      if method_id != method_id.decamelize
        self.__call__(method_id.decamelize, *args)
      else
        if args.length == 0
          self[method_id]
        elsif args.length == 1
          self[method_id] = args[0]
        else
          raise NoMethodError.new(method_id)
        end
      end
    end
  end
  
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
  end

  class NetworkManagerSettings
    class Connection
    end
  end
end
