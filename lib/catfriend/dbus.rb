require 'catfriend/thread'
require 'catfriend/server'
require 'dbus'

module Catfriend # {

SERVICE   = "org.freedesktop.Catfriend"
PATH      = "/org/freedesktop/Catfriend"
INTERFACE = "org.freedesktop.Catfriend.System"

class DBus
    include Thread

    class DBusObject < ::DBus::Object
        dbus_interface INTERFACE do
          dbus_method :stop do
            puts "stopping"
            # todo: actually stop
          end
        end
    end

    def init
        @bus = ::DBus::SessionBus.instance if not @bus
    end

    def shutdown
        init
        service = @bus.service(SERVICE)
        object = service.object(PATH)
        object.introspect
        object.default_iface = INTERFACE
        object.stop
        true
    rescue
        false
    end

    def start_service
        object = DBusObject.new PATH
        service = @bus.request_service(SERVICE)
        service.export object
    end

    def run
        init
        if shutdown
            Catfriend.whisper "shutting down existing catfriend"
            # TODO: wait for response to shutdown method
        else
            start_service
        end

        main = ::DBus::Main.new
        main << @bus
        main.run
    rescue => e
        puts "dbus unknown error #{e.message}\n#{e.backtrace.join("\n")}"
    end
end

end # } end module
