module Catfriend

# Adapt a file to a stack of tokens.
class FileTokenStack
  # Initialize the token stack with the path of the file, the given token
  # match and comment skipping regexs.
  def initialize file, token_match = /\S+/, comment_match = /#.*/
    @token_match   = token_match
    @comment_match = comment_match
    @stream = File.new file, "r"
    @tokens = []
    get_next_tokens
  end

  def get_next_tokens
    # Never let the token stack get empty so that empty? can always
    # work ahead of time.. this wouldn't be good for a network stream as
    # it would block before delivering the last token.
    while @tokens.empty?
      @line = @stream.gets
      return unless @line
      @tokens = @line.sub(@comment_match, '').scan(@token_match) if @line
    end
  end

  # Shift the next token from the current stream position.
  def shift
    ret = @tokens.shift
    get_next_tokens
    ret
  end

  # Report if any tokens remain
  def empty?
    @stream.eof and @tokens.empty?
  end

  private :get_next_tokens
end

end
