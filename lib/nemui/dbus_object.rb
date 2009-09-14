
module NEMUI
  class DBusObject
    def properties
      if @proxy_obj.has_iface?(Interface::PROPERTIES)
        @prop_iface = @proxy_obj[Interface::PROPERTIES]
      else
        raise InterfaceMismatchError.new(Interface::PROPERTIES)
      end
    end

    def [](prop_name)
      prop_name = prop_name.to_s.camelize
      self.properties.Get(self.class::DEFAULT_INTERFACE, prop_name)[0]
    end
    
    def []=(prop_name, value)
      prop_name = prop_name.to_s.camelize
      self.properties.Set(self.class::DEFAULT_INTERFACE, prop_name, value)
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

    def self.interface(iface)
      self.const_set(:DEFAULT_INTERFACE, iface)
    end

    def self.create(path, &block)
      self.__create__(path, &block)
    end

    def self.__create__(path, &block)
      bus = DBus::SystemBus.instance
      service = bus.service(NM_SERVICE)
      obj = service.object(path)
      obj.introspect
      
      if block.nil?
        unless obj.has_iface?(self::DEFAULT_INTERFACE)
          raise InterfaceMismatchError.new(self::DEFAULT_INTERFACE)
        end
        ret_obj = self.new
        ret_obj.instance_eval("@proxy_obj = obj")
        ret_obj.instance_eval("@default_iface = self.class::DEFAULT_INTERFACE")
        ret_obj.instance_eval("@default_iface_obj = @proxy_obj[self.class::DEFAULT_INTERFACE]")
        ret_obj
      elsif block.instance_of?(Proc)
        block.call(obj)
      else
        raise ArgumentError.new(block)
      end
    end
  end
end
