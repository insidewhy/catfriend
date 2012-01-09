# Catfriend

catfriend is a program that checks your e-mail and creates desktop notifications using dbus. It can create notifications on all window managers that support the freedesktop notification specification including KDE, Gnome, Awesome.

Ruby and Python versions are provided.

## Features
* Can check multiple accounts.
* Uses IMAP IDLE to notify as soon as mail arrives rather than polling.
* Simple configuration file format.
* Updates an account's notification if it has not been closed rather than creating duplicate notifications.
* Supports IMAP accounts with or without SSL.
* Does not punish the fearless.

## Installation

### Ruby version
The fourth step is only necessary if you are using a mail-server with a self-signed SSL certificate. This is a security measure to protect you from spoofing.

    $ sudo gem install catfriend
    $ cd ~/.config/catfriend
    $ edit catfriend
    $ wget http://location.to/ssl-certificate.pem
    $ catfriend

### Python version
    $ tar xzvf catfriend-*.tar.gz
    $ cd catfriend-*/
    $ cp catfriend.example ~/.config/catfriend
    $ edit ~/.config/catfriend  # with your favourite editor. mine is vim!
    $ ./python/catfriend.py     # or you can copy this script to your $PATH

## Configuration
The configuration file lives at ~/.config/catfriend. Here is an example config:

    imap imap.gmail.com
        id        fun  # used instead of host in nofifications when available
        user      friend@gmail.com
        password  faptap
        cert_file server.pem  # relative to ~/.config or XDG config dir

    imap insecure.work.com
        user      bossman@work.com
        password  insecure
        nossl # turn off ssl, it is on by default
        work  # mark as work account, -w command-line argument enables it

    # Time notification remains on screen in milliseconds
    notificationTimeout    10000
    errorTimeout           60000  # as above but for error notifications
    socketTimeout          60     # server socket timeout in seconds

    # How often to wait between checks in seconds, only required for Python
    # version as Ruby version uses IMAP IDLE to notify you as soon as mail
    # arrives
    checkInterval          60

## TODO
* Support POP3/Atom/RSS

## Dependencies

### Ruby version
* gtkmm
* gem install libnotify
* gem install xdg (optional)

### Python version
* python-notify

## Comparison

### Ruby pros
* You can terminate the Ruby version at any time with ctrl-C whilst the Python version can get unavoidably stuck for a while waiting on IO due to Python's threading model.
* Ensures your security by forcing you to download SSL certificates for self signed SSL keys.
* Ruby's IMAP library supports the IDLE command so you get notified as soon as new mail arrives; whilst the Python version has to poll for mail at a configurable interval.

### Python pros
* Can be faster depending on your Ruby implementation.
* Accepts self-signed SSL certificates with no fuss (although this is insecure).
* Is no longer being updated so lacks "work" feature.
