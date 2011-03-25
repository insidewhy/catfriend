#!/usr/bin/env python2

import imaplib
import pynotify
from time import sleep
from os import getenv

class MailSource:
    def __init__(self, src_data):
        self.lastUid = 0

        self.host = src_data['host']
        self.user = src_data['user']
        self.password = src_data['password']
        if 'id' in src_data:
            self.id = src_data['id']
        else:
            self.id = self.host

        self.notification = pynotify.Notification("chekor")
        self.notification.set_timeout(timeout)
        if 'no_ssl' in src_data and src_data['no_ssl']:
            self.imap = imaplib.IMAP4(self.host)
        else:
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

        try:
            lastUid = int(res[uidIdx + 1:brackIdx])
            if lastUid > self.lastUid:
                nMessages = res[:spaceIdx]
                self.lastUid = lastUid
                self.notify(nMessages + ' messages')
        except ValueError:
            self.error('bad line returned from fetch')

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
except KeyboardInterrupt:
    print "caught interrupt"
except IOError:
    print "could load configuration file from " + getenv('HOME') + '/.config/catfriend'
