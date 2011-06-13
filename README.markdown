# Catfriend

catfriend is python script that checks your e-mail and creates desktop notifications using dbus. It can create notifications on all window managers that support the freedesktop notification specification including KDE, Gnome, Awesome.

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
    $ ./python/catfriend.py     # or you can copy this script to your $PATH

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

    # time notification remains on screen in milliseconds
    notificationTimeout    10000
    errorTimeout           60000  # as above but for error notifications
    socketTimeout          60     # server socket timeout in seconds
    checkInterval          60     # how often to wait between checks in seconds

## TODO
* Rewrite in C++ and use IMAP idle command rather than polling for instant notifications.

## Dependencies
* python-notify
