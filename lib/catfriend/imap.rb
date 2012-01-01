require 'catfriend/server'
require 'catfriend/notify'

module Catfriend

# This class represents a thread capable of checking and creating
# notifications for a single mailbox on a single IMAP server.
class ImapServer
    include ThreadMixin
    include AccessorsFromHash

    # Create new IMAP server with optional full configuration hash.
    # If the hash is not supplied at construction a further call must be
    # made to #configure before #start is called to start the thread.
    def initialize(args = nil)
        configure args if args
    end

    # Configure all attributes based on hash then make sure this
    # represents a total valid configuration.
    def configure args
        super args

        if not @user
            raise ConfigError, "imap user not set"
        end
        if not @host
            raise ConfigError, "imap host not set"
        end
        if not @password
            raise ConfigError, "imap password not set"
        end

        @id = @host unless @id
    end

    # The id is a token which represents this server when displaying
    # notifications and is set to the host unless over-ridden by the
    # configuration file
    def id ; @id || @host ; end

    # Raise an error related to this particular server.
    def error message
        # consider raising notification instead?
        puts "#{id}: #{message}"
    end

    # ThreadMixin interface. This connects to the mailserver and then
    # runs #check_loop to do the e-mail checking if the connection
    # succeeds.
    def run
        # connect and go
        begin
            connect
            @notification = Libnotify.new do |n|
                n.summary = @id
            end

        rescue OpenSSL::SSL::SSLError
            error "try providing ssl certificate"
        rescue Net::IMAP::NoResponseError
            error "no response to connect, try ssl"
        else
            check_loop
        end
    end

    # Continually waits for new e-mail raising notifications when new
    # e-mail arrives or when error conditions happen. This methods only exits
    # on an unrecoverable error.
    def check_loop
        #
    end

    # Connect to the configured IMAP server.
    def connect
        args = nil
        if not @no_ssl
            if @cert_file
                args = { :ssl => { :ca_file => @cert_file } }
            else
                args = { :ssl => true }
            end
        end
        @imap = Net::IMAP.new(@host, args)
        @imap.login(@user, @password)
        puts @imap.select(@mailbox || "INBOX")
    end

    private :connect, :check_loop, :run, :error
    attr_writer :host, :password, :id, :user, :no_ssl, :cert_file, :mailbox
end

end # end module
