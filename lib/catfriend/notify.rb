require 'libnotify'

# Patch libnotify to add notification updating support. I have pushed
# this patch to the libnotify project and it should drop with 0.7
module Libnotify
  # Re-open to import notification update.
  module FFI
    class << self
        alias_method :orig_attach_functions!, :attach_functions!
    end
    def self.attach_functions!
      attach_function :notify_notification_update,
                      [:pointer, :string, :string, :string, :pointer],
                      :pointer
      orig_attach_functions!
    end
  end

  # Re-open and add update method.
  class API
    # Rewrite show to store notification in an instance variable.
    def show!
      notify_init(self.class.to_s) or raise "notify_init failed"
      @notification = notify_notification_new(summary, body, icon_path, nil)
      notify_notification_set_urgency(@notification, lookup_urgency(urgency))
      notify_notification_set_timeout(@notification, timeout || -1)
      if append
        notify_notification_set_hint_string(@notification, "x-canonical-append", "")
        notify_notification_set_hint_string(@notification, "append", "")
      end
      if transient
        notify_notification_set_hint_uint32(@notification, "transient", 1)
      end
      notify_notification_show(@notification, nil)
    ensure
      notify_notification_clear_hints(@notification) if (append || transient)
    end

    # Updates a previously shown notification.
    def update(&block)
      yield(self) if block_given?
      if @notification
        notify_notification_update(@notification, summary, body, icon_path, nil)
        notify_notification_show(@notification, nil)
      else
        show!
      end
    end
  end
end
