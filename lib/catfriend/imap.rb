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
        begin
            connect
            # :body => nil means summary only
            @notification =
                Libnotify.new :body => nil,
                              :timeout => Catfriend.notification_timeout
        rescue OpenSSL::SSL::SSLError
            error "try providing ssl certificate"
        rescue Net::IMAP::NoResponseError
            error "no response to connect, try ssl"
        else
            @message_count = @imap.fetch('*', 'UID').first.seqno
            notify_message @message_count

            loop { check_loop }
        end
    end

    # Continually waits for new e-mail raising notifications when new
    # e-mail arrives or when error conditions happen. This methods only exits
    # on an unrecoverable error.
    def check_loop
        @imap.idle do |r|
            next if r.instance_of? Net::IMAP::ContinuationRequest

            if r.instance_of? Net::IMAP::UntaggedResponse
                if r.name == 'EXISTS'
                    # some servers send this even when the message count
                    # hasn't increased so suspiciously double-check
                    if r.data > @message_count
                        @message_count = r.data
                        notify_message @message_count
                    end
                elsif r.name == 'EXPUNGE'
                    @message_count -= 1
                end
            end
        end

        notify_message "error - server cancelled idle"
    rescue => e
        # todo: see if we have to re-open socket
        notify_message "error - #{e.message}"
    end

    def notify_message message
        @notification.update { |n| n.summary = "#{id}: #{message}" }
        # puts @notification.summary # debug code
    end

    def kill
        disconnect
        super
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
        @imap.select(@mailbox || "INBOX")
    end

    def disconnect ; @imap.disconnect ; end

    private :connect, :disconnect, :check_loop, :run, :error, :notify_message
    attr_writer :host, :password, :id, :user, :no_ssl, :cert_file, :mailbox
end

end # end module
