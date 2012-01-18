require 'catfriend/thread'
require 'dbus'

module Catfriend # {

SERVICE   = "org.freedesktop.Catfriend"
PATH      = "/org/freedesktop/Catfriend"
INTERFACE = "org.freedesktop.Catfriend.System"

class DBusClient
    def self.shutdown
        bus = DBus::SessionBus.instance
        service = bus.service(SERVICE)
        object = service.object(PATH)
        object.introspect
        object.default_iface = INTERFACE
        object.stop
        true
    rescue
        false
    end
end

class DBusServer
    include Thread

    class DBusObject < DBus::Object
        dbus_interface INTERFACE do
          dbus_method :stop do
            puts "stopping"
            # todo: actually stop
          end
        end
    end

    def run
        object = DBusObject.new PATH
        bus = DBus::SessionBus.instance
        service = bus.request_service(SERVICE)
        service.export object
        main = DBus::Main.new
        main << bus
        main.run
    rescue => e
        puts "dbus unknown error #{e.message}\n#{e.backtrace.join("\n")}"
    end
end

end # } end module
