#!/usr/bin/env ruby

require 'rubygems'
require 'dbus'


require 'nemui/interface'
require 'nemui/properties'
require 'nemui/network_manager'
require 'nemui/network_manager_settings'

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
end
