require 'libnotify'
require 'catfriend/server'
require 'catfriend/thread'

# unless I do this I get random errors from Libnotify on startup 90% of the
# time... this could be a bug in autoload or ruby 1.9 rather than libnotify
module Libnotify
    class API ; end
end

module Catfriend

# This class represents a thread capable of checking and creating
# notifications for a single mailbox on a single IMAP server.
class ImapServer
    include Thread
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
            @notification =
                Libnotify.new :body => nil,
                              :timeout => Catfriend.notification_timeout
            @message_count = connect
            notify_message @message_count
            # :body => nil means summary only
        rescue OpenSSL::SSL::SSLError
            error "try providing ssl certificate"
        rescue Net::IMAP::NoResponseError
            error "no response to connect, try ssl"
        else
            loop {
                check_loop
                break if stopping?
            }
        end
    end

    # Continually waits for new e-mail raising notifications when new
    # e-mail arrives or when error conditions happen. This methods only exits
    # on an unrecoverable error.
    def check_loop
        @imap.idle do |r|
            Catfriend.whisper "#{id}: #{r}"
            next if r.instance_of? Net::IMAP::ContinuationRequest

            if r.instance_of? Net::IMAP::UntaggedResponse
                case r.name
                when 'EXISTS'
                    # some servers send this even when the message count
                    # hasn't increased so suspiciously double-check
                    if r.data != @message_count
                        notify_message(r.data) if r.data > @message_count
                        @message_count = r.data
                    end
                when 'EXPUNGE'
                    @message_count -= 1
                end
            end
        end

        Catfriend.whisper "idle loop over"
    rescue Net::IMAP::Error, IOError
        # reconnect and carry on
        reconnect unless stopping?
    rescue => e
        unless stopping?
            # todo: see if we have to re-open socket
            notify_message "#{@message_count} [error: #{e.message}]"
            puts e.backtrace.join "\n"
        end
    end

    def notify_message message
        @notification.update :summary => "#{id}: #{message}"
        Catfriend.whisper @notification.summary
    end

    def stopping?
        stopped? or @stopping
    end

    def kill
        @stopping = true
        disconnect
        super
    end

    # Connect to the configured IMAP server and return message count.
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
        return @imap.fetch('*', 'UID').first.seqno
    end

    def reconnect
        notify_message "#{@message_count} [reconnecting]"
        new_count = connect
        if new_count != @message_count
            notify_message new_count
        else
            # todo: only if it was still open
            @notification.close
        end
        @message_count = new_count
    end

    def disconnect ; @imap.disconnect ; end

    private :connect, :disconnect, :reconnect,
            :check_loop, :run, :error, :notify_message

    attr_writer :host, :password, :id, :user, :no_ssl, :cert_file, :mailbox
    attr_accessor :work_account
end

end # end module
