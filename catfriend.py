#!/usr/bin/env python2

import imaplib
import pynotify
from time import sleep
from os import getenv

class MailSource:
    def __init__(self, src_data):
        self.lastUid = 0
        self.id = src_data['id']
        self.user = src_data['user']
        self.password = src_data['password']
        self.host = src_data['host']
        self.notification = pynotify.Notification("chekor")
        self.notification.set_timeout(timeout)
        self.imap = imaplib.IMAP4_SSL(self.host)
        self.loggedIn = self.login()
        if not self.loggedIn:
            self.notify("could not login")

    def login(self):
        try:
            self.imap.login(self.user, self.password)
            return True
        except:
            return False

    def run(self):
        if not self.loggedIn:
            if self.login():
                self.notify("logged back in")
                self.loggedIn = True
            else: return

        self.imap.select('INBOX', True)
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

        lastUid = res[uidIdx + 1:brackIdx]
        if lastUid > self.lastUid:
            nMessages = res[:spaceIdx]
            self.lastUid = lastUid
            self.notification.update(self.id + ': ' + nMessages + ' messages')
            self.notification.show()

    def error(self, errStr):
        notify(self, errStr)

    def notify(self, notStr):
        self.notification.update(self.id + ': ' + notStr)
        self.notification.show()

def main():
    pynotify.init("basics")

    checks = []
    for source in sources:
        checks.append(MailSource(source))

    while True:
        for check in checks:
            check.run()
        sleep(checkInterval)

try:
    execfile(getenv('HOME') + '/.config/catfriend')
    main()
except KeyboardInterrupt, e:
    print "caught interrupt"
except IOError, e:
    print "could load configuration file from " + getenv('HOME') + '/.config/catfriend'
