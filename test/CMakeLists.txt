add_executable(imap imap.cpp)
target_link_libraries(imap
                      ${Boost_SYSTEM_LIBRARY}
                      ${OPENSSL_LIBRARIES})

add_executable(dbus dbus.cpp)
target_link_libraries(dbus ${DBUS_LIBRARIES})
