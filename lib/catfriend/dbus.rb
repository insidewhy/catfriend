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
        def initialize(main, servers)
            @main    = main
            @servers = servers
            super PATH
        end

        dbus_interface INTERFACE do
          dbus_method :stop do
            Catfriend.whisper "received shutdown request"
            @main.quit  # this must be run from within method handler
            @servers.each { |s| s.disconnect }
          end
        end
    end

    def initialize(servers = nil)
        @servers = servers
    end

    def init
        @bus = ::DBus::SessionBus.instance unless @bus
    end

    def send_shutdown
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
        object = DBusObject.new(@main, @servers)
        service = @bus.request_service(SERVICE)
        service.export object
    end

    def run
        init
        if send_shutdown
            Catfriend.whisper "shut down existing catfriend"
        end

        @main = ::DBus::Main.new
        start_service
        @main << @bus
        @main.run
    rescue => e
        puts "dbus unknown error #{e.message}\n#{e.backtrace.join("\n")}"
    end
end

end # } end module
