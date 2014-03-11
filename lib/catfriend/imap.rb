require 'libnotify'
require 'events'
require 'net/imap'

require_relative 'server'
require_relative 'thread'
require_relative 'net_imap_exchange_patch'

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
  include Events::Emitter

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

    raise ConfigError, "imap user not set" unless @user
    raise ConfigError, "imap host not set" unless @host
    raise ConfigError, "imap password not set" unless @password
  end

  # The id is a token which represents this server when displaying
  # notifications and is set to the host unless over-ridden by the
  # configuration file
  def id ; @id || @host ; end

  # Raise an error related to this particular server.
  def error message
    emit :error, message
  end

  # ThreadMixin interface. This connects to the mailserver and then
  # runs #sleep_until_change to do the e-mail checking if the connection
  # succeeds.
  def run
    begin
      @notification =
        Libnotify.new :body => nil, :timeout => Catfriend.notification_timeout
      @message_count = connect
      notify_message @message_count
      # :body => nil means summary only
    rescue OpenSSL::SSL::SSLError
      error "try providing ssl certificate"
    rescue Net::IMAP::NoResponseError
      error "no response to connect, try ssl"
    else
      loop {
        sleep_until_change
        break if stopping?
      }
    end
  end

  # Waits until an event occurs which could change the message count.
  def sleep_until_change
    @imap.idle do |r|
      begin
        Catfriend.whisper "#{id}: #{r}"
        next if r.instance_of? Net::IMAP::ContinuationRequest

        if r.instance_of? Net::IMAP::UntaggedResponse
          case r.name
          when 'EXISTS', 'EXPUNGE'
            @imap.idle_done
          end
        end
      rescue => e
        error e.message
      end
    end

    Catfriend.whisper "idle loop over"
    count = get_unseen_count
    if count != @message_count
      notify_message(count) if count > @message_count
      @message_count = count
    end
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

  # Update the associated notification with message and show it if it is not
  # already displayed.
  def notify_message message
    @notification.update :summary => "#{id}: #{message}"
    Catfriend.whisper @notification.summary
  end

  # Returns false until kill/disconnect have been called.
  def stopping?
    stopped? or @stopping
  end

  # Disconnect from the imap server and stop the associated thread.
  def kill
    disconnect
    super
  end

  # Ask IMAP server for count of unseen messages.
  def get_unseen_count
    begin
      # fetch raises an exception when the mailbox is empty
      @imap.status(@mailbox || "INBOX", ["UNSEEN"])["UNSEEN"]
    rescue => e
      error "failed to get count of unseen messages"
      0
    end
  end

  # Connect to the configured IMAP server and return message count.
  def connect
    args = nil
    unless @no_ssl
      if @cert_file
        args = { :ssl => { :ca_file => @cert_file } }
      else
        args = { :ssl => true }
      end
    end
    @imap = Net::IMAP.new(@host, args)
    @imap.login(@user, @password)
    @imap.select(@mailbox || "INBOX")

    get_unseen_count
  end

  # Reconnect to the server showing a "[reconnecting]" message. After
  # reconnection then show the message count if it has changed from
  # what was remembered before the disconnect.
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

  def disconnect
    @stopping = true
    @imap.disconnect
  end

  private :connect, :reconnect, :sleep_until_change, :run, :error, :notify_message

  attr_writer :host, :password, :id, :user, :no_ssl, :cert_file, :mailbox
  attr_accessor :work_account
end

end
