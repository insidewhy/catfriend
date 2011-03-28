#!/usr/bin/env python2

import imaplib
import pynotify
from time import sleep
from os import getenv
from io import open
from re import compile as regex

sources       = []
timeout       = 10000
checkInterval = 60

class IncompleteSource(Exception):
    def __init__(self, id, value):
        self.id = id
        self.value = value
    def __str__(self):
        return self.id + ': ' + self.value

class MailSource:
    def __init__(self, host):
        self.host = host
        self.id = host
        self.user = None
        self.password = None
        self.noSsl = False

    def reconnect(self):
        self.imap.shutdown()
        self.imap.open(self.host)
        self.loggedIn = self.login()
        if not self.loggedIn:
            self.error("could not login after reconnection")

    def init(self):
        self.lastUid      = 0
        self.notification = pynotify.Notification("catfriend")
        self.notification.set_timeout(timeout)

        if self.user is None:
            raise IncompleteSource(self.id, "missing user")

        if self.password is None:
            raise IncompleteSource("missing password")

        if self.noSsl:
            self.imap = imaplib.IMAP4(self.host)
        else:
            self.imap = imaplib.IMAP4_SSL(self.host)

        self.loggedIn = self.login()
        if not self.loggedIn:
            self.error("could not login")

    def login(self):
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
        try:
            self.__run()
        except socket.error:
            self.error("server closed socket, reconnecting")
            self.reconnect()

    def error(self, errStr):
        notify(self, errStr)

    def notify(self, notStr):
        self.notification.update(self.id + ': ' + notStr)
        self.notification.show()

    def __str__(self):
        return self.id


def main():
    global sources
    pynotify.init("basics")

    for source in sources:
        source.init()

    while True:
        for source in sources:
            source.run()
        sleep(checkInterval)

def readConfig():
    global timeout, checkInterval, sources

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

        if res[0] == "timeout":
            timeout = int(res[1])
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

try:
    res = readConfig()
except IOError:
    print "could not load configuration file from " + getenv('HOME') + '/.config/catfriend'

try:
    if res:
        print "bad config line `" + res[:-1] + "'"
    main()
except KeyboardInterrupt:
    print "caught interrupt"
except IncompleteSource, e:
    print e
