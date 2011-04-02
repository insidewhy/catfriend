add_executable(imap imap.cpp)
target_link_libraries(imap
                      ${DBUS_LIBRARIES}
                      ${Boost_SYSTEM_LIBRARY}
                      ${OPENSSL_LIBRARIES})
