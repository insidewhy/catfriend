# Catfriend

catfriend is python script that checks your e-mail and creates desktop notifications using dbus. This means it can create notifications on KDE, Gnome, Awesome and all other window managers that support the notification specification.

## Features
* Can check multiple accounts.
* Updates an account's notification if it has not been closed rather than creating duplicate notifications.
* Supports IMAP accounts with or without SSL.
* Does not punish the fearless.

## Installation
    $ tar xzvf catfriend-*.tar.gz
    $ cd catfriend-*/
    $ cp catfriend.example ~/.config/catfriend
    $ edit ~/.config/catfriend  # with your favourite editor. mine is vim!
    $ ./catfriend.py            # or you can copy this script to your $PATH

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

    # time notification remains on screen in milliseconds, the rest are in seconds
    notificationTimeout    10000
    socketTimeout          60
    checkInterval          60

## Dependencies
* python-notify
