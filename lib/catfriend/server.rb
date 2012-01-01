module Catfriend

def self.notification_timeout
    @@notification_timeout
end

# Mixin this module and define "run" for a simple runnable/joinable thread
module ThreadMixin
    # Call to start a thread running via the start method.
    def start ; @thread = Thread.new { run } ; end

    # Join thread started with start.
    def join ; @thread.join ; end
end

# Mixin to provide #configure which allows all instance variables with write
# accessors declared to be set from a hash.
module AccessorsFromHash
    # Call this to tranfer the hash data to corresponding attributes. Any
    # hash keys that do not have a corresponding write accessor in the
    # class are silently ignored.
    def configure args
        args.each do |opt, val|
            instance_variable_set("@#{opt}", val) if respond_to? "#{opt}="
        end
    end
end

# This class is used to signal the user made an error in their configuration.
class ConfigError < Exception ; end

end # end module
