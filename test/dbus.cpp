#include <dbus/dbus.h>
#include <iostream>
#include <stdlib.h>
#include <assert.h>

#define CF_NOTIFY_NAME  "org.freedesktop.Notifications"
#define CF_NOTIFY_OPATH "/org/freedesktop/Notifications"
#define CF_NOTIFY_IFACE "org.freedesktop.Notifications"
#define CF_NOTIFY_NOTE  "Notify"

bool checkError(const char* msg, const DBusError* error) {
    assert(msg);
    assert(error);

    if (dbus_error_is_set(error)) {
        // error->name/message
        std::cerr << "error: " << msg << "( " << error->name << ", "
                  << error->message << " )" << std::endl;
        return true;
    }
    return false;
}

int main(int argc, char** argv) {
    DBusConnection* bus = 0;
    DBusMessage* msg = 0;
    DBusError error;

    const char* appName = "type";
    const char* summary = "Hello World!";
    const char* notBody = "Hello World!";
    const char* actions[] = { };
    const char* nullStr = "";
    int replacesId = 0;
    int timeout = 5000;

    dbus_error_init(&error);

    bus = dbus_bus_get(DBUS_BUS_SESSION, &error);
    if (checkError("Failed to open Session bus\n", &error)) return 1;
    assert(bus);

    if (!dbus_bus_name_has_owner(bus, CF_NOTIFY_NAME, &error)) return 1;
    if (checkError("Failed to check for name ownership\n", &error)) {
        return 1;
    }
    msg = dbus_message_new_method_call(
        CF_NOTIFY_NAME, CF_NOTIFY_OPATH, CF_NOTIFY_IFACE, CF_NOTIFY_NOTE);
    if (! msg) return 1;

    dbus_message_set_no_reply(msg, FALSE);

    if (! dbus_message_append_args(
            msg,
            DBUS_TYPE_STRING, &appName,
            DBUS_TYPE_UINT32, &replacesId,
            DBUS_TYPE_STRING, &nullStr,
            DBUS_TYPE_STRING, &nullStr,
            DBUS_TYPE_STRING, &notBody,
            DBUS_TYPE_ARRAY, DBUS_TYPE_STRING, &actions, 0,
            DBUS_TYPE_ARRAY, DBUS_TYPE_STRING, &actions, 0,
            DBUS_TYPE_UINT32, &timeout,
            DBUS_TYPE_INVALID))
    { return 1; }

    if (! dbus_connection_send_with_reply_and_block(bus, msg, 5000, 0)) {
        return 1;
    }

    // dbus_connection_flush(bus);
    dbus_message_unref(msg);
    msg = 0;

    dbus_connection_unref(bus);
    bus = 0;

    return 0;
}
