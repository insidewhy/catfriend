#include <catfriend/ImapClient.hpp>

namespace asio = boost::asio;

int main(int argc, char* argv[]) {
    if (argc != 4) {
        std::cerr << "Usage: client <host> <user> <password>\n";
        return 1;
    }

    try {
        asio::io_service io_service;

        asio::ip::tcp::resolver resolver(io_service);
        asio::ip::tcp::resolver::query query(argv[1], "imaps");
        asio::ip::tcp::resolver::iterator iterator = resolver.resolve(query);

        catfriend::imap::SslClient c1(io_service, iterator, argv[2], argv[3]);

        io_service.run();
    }
    catch (std::exception& e) {
        std::cerr << "unknown error: " << e.what() << '\n';
    }

    return 0;
}
