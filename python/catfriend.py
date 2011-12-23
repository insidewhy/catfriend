#!/usr/bin/env python2

from getopt import getopt, GetoptError
import imaplib
import pynotify
import socket
import threading
from time import sleep
from os import getenv
from io import open
from sys import exc_info, argv, stdout
from re import compile as regex
from traceback import print_exc

CATFRIEND_VERSION = "1"
CATFRIEND_NAME    = "arpacasio"

sources              = []
notificationTimeout  = 10000 # milliseconds
errorTimeout         = 60000 # milliseconds, rest are in seconds
socketTimeout        = 60
checkInterval        = 60
verbose              = False

class IncompleteSource(Exception):
    def __init__(self, id, value):
        self.id = id
        self.value = value
    def __str__(self):
        return self.id + ': ' + self.value

class Notification:
    def __init__(self):
        self.notification = pynotify.Notification("catfriend")
        self.notification.set_timeout(notificationTimeout)

    def update(self, string):
        self.notification.update(string)
        self.notification.show()

class MailSource(threading.Thread):
    def __init__(self, host):
        self.host = host
        self.id = host
        self.user = None
        self.password = None
        self.noSsl = False
        self.stopped = False
        threading.Thread.__init__(self)

    def reconnect(self, errStr):
        try:
            self.__reconnect(errStr)
        except KeyboardInterrupt:
            raise
        except:
            self.error(errStr + " - could not reconnect")
            print_exc(file=stdout)
            return

    def __reconnect(self, errStr):
        self.error(errStr + " - reconnecting")
        self.imap.shutdown()
        self.__connect()
        self.disconnected = False
        self.loggedIn = self.login()
        if not self.loggedIn:
            self.error(errStr + " - reconnected but could not login")
        else:
            self.error(errStr + " - reconnected and logged in")

    def __connect(self):
        if self.noSsl:
            self.imap = imaplib.IMAP4(self.host)
        else:
            self.imap = imaplib.IMAP4_SSL(self.host)
        self.disconnected = False

    def init(self):
        self.condition    = threading.Condition()
        self.lastUid      = 0
        self.notification = Notification()

        if self.user is None:
            raise IncompleteSource(self.id, "missing user")

        if self.password is None:
            raise IncompleteSource("missing password")

        self.__connect()

        self.loggedIn = self.login()
        if not self.loggedIn:
            self.error("could not login")

    def login(self):
        if self.disconnected:
            self.imap.shutdown()
            self.__connect()

        self.imap.socket().settimeout(socketTimeout)

        try:
            self.imap.login(self.user, self.password)
            return True
        except:
            return False

    def __run(self):
        if not self.loggedIn:
            if self.login():
                self.notify("logged back in")
                self.loggedIn = True
            else: return

        res = self.imap.select('INBOX', True)
        if res[0] != 'OK':
            if len(res[1]):
                self.error('bad response to IMAP select: ' + res[1][0])
            else:
                self.error('unknown response to IMAP select')
            return

        res = self.imap.fetch('*', '(UID)')
        if res[0] != 'OK' or not len(res[1]):
            self.error('problem with fetch')
            return

        res = res[1][0]
        spaceIdx = res.find(' ')
        uidIdx = res.find(' ', spaceIdx + 1)
        brackIdx = res.find(')', uidIdx)

        if uidIdx == -1 or brackIdx == -1:
            self.error('bad line returned from fetch')
            return

        try:
            lastUid = int(res[uidIdx + 1:brackIdx])
            if lastUid > self.lastUid:
                nMessages = res[:spaceIdx]
                self.lastUid = lastUid
                self.notify(nMessages + ' messages')
        except ValueError:
            self.error('bad line returned from fetch')

    def run(self):
        self.condition.acquire()
        global checkInterval
        while not self.stopped:
            try:
                self.__run()
                self.condition.wait(checkInterval)
            except socket.error:
                self.reconnect("socket error")
            except socket.timeout:
                self.reconnect("socket timeout")
            except imaplib.IMAP4.abort:
                self.reconnect("imaplib abort error")

    def stop(self):
        # call this from master thread
        self.stopped = True
        self.condition.acquire()
        self.condition.notify()
        self.condition.release()

    def error(self, errStr):
        self.notify(errStr)

    def notify(self, notStr):
        if verbose: print(self.id + ': ' + notStr)
        self.notification.update(self.id + ': ' + notStr)

    def __str__(self):
        return self.id

def run():
    global sources

    for source in sources:
        source.init()

    for source in sources:
        source.start()

    try:
        # to allow keyboard interrupt to be caught
        while True: sleep(100)
    except KeyboardInterrupt:
        for source in sources:
            source.stop()

    for source in sources:
        source.join()

def readConfig():
    global notificationTimeout, errorTimeout, socketTimeout, \
           checkInterval, sources

    currentSource = None
    file = open(getenv('HOME') + '/.config/catfriend', 'r')
    re = regex("^\s*(?:([a-zA-Z]+)(?:\s+(\S+))?\s*)?(?:#.*)?$")

    checks = []
    for source in sources:
        checks.append(MailSource(source))

    while True:
        line = file.readline()
        if not line: break
        res = re.match(line)
        if not res:
            return line

        res = res.groups()
        if res[0] is None: continue

        if res[0] == "notificationTimeout":
            notificationTimeout = int(res[1])
        elif res[0] == "errorTimeout":
            errorTimeout = int(res[1])
        elif res[0] == "socketTimeout":
            socketTimeout = int(res[1])
        elif res[0] == "checkInterval":
            checkInterval = int(res[1])
        elif res[0] == "host":
            if currentSource:
                sources.append(currentSource)
            currentSource = MailSource(res[1])
        elif currentSource is None:
            return line
        elif not res[1]:
            if res[0] == "nossl":
                currentSource.noSsl = True
            else:
                return line
        elif res[0] == "id":
            currentSource.id = res[1]
        elif res[0] == "user":
            currentSource.user = res[1]
        elif res[0] == "password":
            currentSource.password = res[1]
        else:
            return line

    sources.append(currentSource)

def usage():
    print "catfriend", CATFRIEND_VERSION, CATFRIEND_NAME
    print "usage: catfriend [args]"
    print "  -h  show help"
    print "  -v  increase verbosity"

def main():
    global verbose

    try:
        opts, args = getopt(argv[1:], "hv")
    except GetoptError, e:
        print(e)
        usage()
        return

    for o, a in opts:
        if o == "-v":
            verbose = True
        elif o == "-h":
            usage()
            return

    try:
        res = readConfig()
    except IOError:
        print "could not load configuration file from " + getenv('HOME') + '/.config/catfriend'
        return

    if res:
        print "bad config line `" + res[:-1] + "'"
        return

    try:
        pynotify.init("basics")
        run()
        return
    except KeyboardInterrupt   : raise
    except IncompleteSource, e : print e
    except:
        print "unknown error:", exc_info()[0]
        print_exc(file=stdout)

    errNot = pynotify.Notification("catfriend exiting due to error")
    errNot.set_timeout(errorTimeout)
    errNot.show()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print "caught interrupt"
