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
    sources = [
        {
            'id'       : 'work',  # name for account, used in notifications
            'user'     : 'mrbossman@work.com',
            'password' : 'supersecret,
            'host'     : 'secure.work.com',
            'no_ssl'   : True,  # ssl is on by default
        },
        {
            # if id is not present the imap host is displayed instead
            'user'     : 'myfriend@gmail.com',
            'password' : 'superkit',
            'host'     : 'imap.gmail.com',
        },
    ]
    timeout       = 5000 # how many milliseconds notifications appear for
    checkInterval = 60   # how many seconds to wait between checking

## Dependencies
* python-notify
