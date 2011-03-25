# Catfriend

catfriend is python script that checks your e-mail and creates desktop notifications using dbus. This means it can create notifications on KDE, Gnome, Awesome and all other window managers that support the notification specification.

## Features
* Can check multiple accounts.
* Updates an account's notification if it has not been closed rather than creating duplicate notifications.
* Supports IMAP accounts with or without SSL.

## Installation
    $ git clone git://github.com/tuxjay/catfriend.git
    $ cp catfriend/catfriend.example ~/.config/catfriend
    $ ./catfriend/catfriend.py

## Configuration
The configuration file lives at ~/.config/catfriend. Here is an example config:
    host secure.work.com
        user      bossman@work.com
        password  secure
        nossl # turn off ssl, it is on by default

    host imap.gmail.com
        id        fun  # used instead of host in nofifications when available
        user      friend@gmail.com
        password  faptap

    timeout        50000000 # in milliseconds
    checkInterval  60   # in seconds

## Dependencies
* python-notify
