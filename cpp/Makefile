.PHONY: all

all: test dbus

test: test.cpp client.hpp
	${CXX} -I. -o $@ $< -l ssl -pthread -l boost_system

dbus: dbus.cpp
	${CXX} -I. -I/usr/include/dbus-1.0 -I/usr/lib/dbus-1.0/include -o $@ $< -ldbus-1
