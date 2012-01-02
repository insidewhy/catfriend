require 'libnotify'

# Patch libnotify to add support for closing a notification.
module Libnotify
  # Re-open to import notification update.
  module FFI
    class << self
        alias_method :orig_attach_functions!, :attach_functions!
    end
    def self.attach_functions!
      attach_function :notify_notification_close,
                      [:pointer, :pointer],
                      :bool
      orig_attach_functions!
    end
  end

  # Re-open to add new APIs
  class API
    # Close notification
    def close
      if @notification
        notify_notification_close(@notification, nil)
      end
    end
  end
end
