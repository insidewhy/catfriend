require_relative 'thread'
require_relative 'server'
require 'dbus'

module Catfriend

SERVICE   = "org.freedesktop.Catfriend"
PATH      = "/org/freedesktop/Catfriend"
INTERFACE = "org.freedesktop.Catfriend.System"

# Represent a DBUS server interface and includes an associated thread
# in which to run the dbus methods.
class DBus
  include Thread

  # This child class fulfils the DBus::Object interface
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

  # Initialize the object with a reference to each Imap object.
  def initialize(servers = nil)
    @servers = servers
  end

  # Start the DBus interface
  def init
    @bus = ::DBus::SessionBus.instance unless @bus
  end

  # Attempt to shutdown another application listening on catfriend's address.
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

  # Call send_shutdown then start the DBus interface.
  def start_service
    object = DBusObject.new(@main, @servers)
    service = @bus.request_service(SERVICE)
    service.export object
  end

  # Run the DBus server in its own ruby thread.
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

end
