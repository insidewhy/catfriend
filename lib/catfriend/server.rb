module Catfriend

class << self
  attr_accessor :notification_timeout, :verbose

  # puts something if -v was used
  def whisper *args
    puts *args if verbose
  end
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

end # end Catfriend module
