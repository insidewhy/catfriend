module Catfriend

# Mixin this module and define "run" for a simple runnable/joinable thread
module Thread
  # Call to start a thread running via the start method.
  def start ; @thread = ::Thread.new { run } ; end

  # Test whether thread is currently stopped or closing down.
  def stopped? ; @thread.nil? ; end

  # Join thread if it has started.
  def join
    unless stopped?
      @thread.join
      @thread = nil
    end
  end


  # Kill thread if it has started.
  def kill
    unless stopped?
      @thread.kill
      @thread = nil
    end
  end
end

end # end Catfriend module
