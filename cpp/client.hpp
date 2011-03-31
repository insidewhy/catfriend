#include <boost/bind.hpp>
#include <boost/asio.hpp>
#include <boost/asio/ssl.hpp>

#include <iostream>
#include <cstring>
#include <string>

namespace catfriend {

namespace asio = boost::asio;

int const MAX_LENGTH = 1024 * 4;

struct client;

template <class T = client>
struct basic_client {
    T&       mixin()       { return static_cast<T &>(*this); }
    T const& mixin() const { return static_cast<T &>(*this); }
};

struct client : basic_client<client> {
};

struct ssl_client : basic_client<ssl_client> {
    void handle_connect(boost::system::error_code const&    error,
                        asio::ip::tcp::resolver::iterator   endpoint_iterator)
    {
        if (! error) {
            socket_.async_handshake(asio::ssl::stream_base::client,
                boost::bind(&ssl_client::handle_handshake, this,
                    asio::placeholders::error));
        }
        else if (endpoint_iterator != asio::ip::tcp::resolver::iterator()) {
            socket_.lowest_layer().close();
            asio::ip::tcp::endpoint endpoint = *endpoint_iterator;
            socket_.lowest_layer().async_connect(endpoint,
                    boost::bind(&ssl_client::handle_connect, this,
                        asio::placeholders::error, ++endpoint_iterator));
        }
        else {
            // TODO: report error
        }
    }

    void handle_handshake(boost::system::error_code const & error) {
        if (error) {
            // TODO: report error
            return;
        }

        char loginPrefix[] = ". login ";
        std::strncpy(request_, loginPrefix, sizeof(loginPrefix) - 1);
        char *ptr = request_ + sizeof(loginPrefix) - 1;
        std::strncpy(ptr, user_.c_str(), user_.size());
        ptr += user_.size();
        *ptr = ' ';
        std::strncpy(++ptr, password_.c_str(), password_.size());
        ptr += password_.size();
        *ptr = '\n';

        asio::async_write(socket_,
                asio::buffer(request_, ptr - request_ + 1),
                boost::bind(&ssl_client::handle_write, this,
                    asio::placeholders::error,
                    asio::placeholders::bytes_transferred));

        asio::async_read(socket_,
                asio::buffer(response_, MAX_LENGTH),
                asio::transfer_at_least(1),
                boost::bind(&ssl_client::handle_read, this,
                    asio::placeholders::error,
                    asio::placeholders::bytes_transferred));
    }

    void handle_write(boost::system::error_code const& error,
                      size_t const                     n_bytes)
    {
        if (error) {
            // TODO: report error
            return;
        }
    }

    void handle_read(boost::system::error_code const& error,
                     size_t const                     n_bytes)
    {
        if (error) {
            // TODO: report error
            return;
        }

        std::cout << "imap server: ";
        std::cout.write(response_, n_bytes);

        asio::async_read(socket_,
                asio::buffer(response_, MAX_LENGTH),
                asio::transfer_at_least(1),
                boost::bind(&ssl_client::handle_read, this,
                    asio::placeholders::error,
                    asio::placeholders::bytes_transferred));
    }

    ssl_client(asio::io_service&                 io_service,
               asio::ip::tcp::resolver::iterator endpoint_iterator,
               std::string const&                user,
               std::string const&                password)
      : ssl_ctxt_(io_service, asio::ssl::context::sslv23),
        socket_(io_service, ssl_ctxt_),
        user_(user), password_(password)
    {
        ssl_ctxt_.set_verify_mode(asio::ssl::context::verify_none);
        asio::ip::tcp::endpoint endpoint = *endpoint_iterator;
        socket_.lowest_layer().async_connect(endpoint,
                boost::bind(&ssl_client::handle_connect, this,
                    asio::placeholders::error, ++endpoint_iterator));
    }

  private:
    asio::ssl::context                       ssl_ctxt_;
    asio::ssl::stream<asio::ip::tcp::socket> socket_;
    char                                     request_[MAX_LENGTH];
    char                                     response_[MAX_LENGTH];
    std::string                              user_;
    std::string                              password_;
};

}
