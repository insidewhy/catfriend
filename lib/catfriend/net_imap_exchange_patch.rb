require 'net/imap'

# This patch is needed because microsoft exchange servers do not correctly implement
# the IMAP specification. Specifially Net::IMAP#status will not work without it.
#
# source:
# http://claudiofloreani.blogspot.co.uk/2012/01/monkeypatching-ruby-imap-class-to-build.html
# thank you!

module Net
  class IMAP
    class ResponseParser
      def response
        token = lookahead
        case token.symbol
        when T_PLUS
          result = continue_req
        when T_STAR
          result = response_untagged
        else
          result = response_tagged
        end
        match(T_SPACE) if lookahead.symbol == T_SPACE
        match(T_CRLF)
        match(T_EOF)
        return result
      end
    end
  end
end
