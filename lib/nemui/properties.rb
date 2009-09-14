
module NEMUI
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
end
