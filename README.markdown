# Catfriend

catfriend is python script that checks your e-mail and creates desktop notifications using dbus. This means it can create notifications on KDE, Gnome, Awesome and all other window managers that support the notification specification.

# Features
* Updates an account's notification if it has not been closed rather than creating duplicate notifications.
* Supports IMAP accounts with or without SSL.

## Installation
    $ git clone git://github.com/tuxjay/catfriend.git
    $ cp catfriend/catfriend.sample.config ~/.config/catfriend
    $ ./catfriend/catfriend.py

## Configuration
The configuration file lives at ~/.config/catfriend. Here is a sample:
    sources = [
        {
            'id'       : 'work',
            'user'     : 'mrbossman@work.com',
            'password' : 'supersecret,
            'host'     : 'secure.work.com'
        },
        {
            'id'       : 'gmail',
            'user'     : 'myfriend@gmail.com',
            'password' : 'superkit',
            'host'     : 'imap.gmail.com'
        },
    ]
    timeout       = 5000 # in milliseconds
    checkInterval = 60   # in seconds

## Dependencies
* python-notify
