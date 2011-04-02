cmake_minimum_required(VERSION 2.8)
project(catfriend)

find_package(Boost COMPONENTS system REQUIRED)
find_package(OpenSSL REQUIRED)

find_path(DBUS_INCLUDE_DIR dbus/dbus.h
    /usr/include
    /usr/include/dbus-1.0
    /usr/local/include)

find_path(DBUS_ARCH_INCLUDE_DIR dbus/dbus-arch-deps.h
    /usr/lib${LIB_SUFFIX}/include
    /usr/lib${LIB_SUFFIX}/dbus-1.0/include
    /usr/lib64/include
    /usr/lib64/dbus-1.0/include
    /usr/lib/include
    /usr/lib/dbus-1.0/include)

find_library(DBUS_LIBRARIES NAMES dbus-1 dbus)
if (NOT DBUS_LIBRARIES OR NOT DBUS_INCLUDE_DIR OR NOT DBUS_ARCH_INCLUDE_DIR)
    message(FATAL_ERROR "dbus not found")
endif()

include_directories(${DBUS_INCLUDE_DIR}
                    ${DBUS_ARCH_INCLUDE_DIR}
                    ${CMAKE_CURRENT_SOURCE_DIR}/..)

add_subdirectory(test)
