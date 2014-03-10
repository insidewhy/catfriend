# Catfriend

catfriend is a ruby program that checks your e-mail and creates desktop notifications using dbus. It can create notifications on all window managers that support the freedesktop notification specification including KDE, Gnome, Awesome.

## Features
 * Can check multiple accounts.
 * Uses IMAP IDLE to notify as soon as mail arrives rather than polling.
 * Simple configuration file format.
 * Updates an account's notification if it has not been closed rather than creating duplicate notifications.
 * Supports IMAP accounts with or without SSL.
 * Can be shut down using dbus (catfriend -s).
 * Does not punish the fearless.

## Installation

The fourth step is only necessary if you are using a mail-server with a self-signed SSL certificate. This is a security measure to protect you from spoofing.

    $ gem install catfriend
    $ cd ~/.config/catfriend
    $ edit catfriend
    $ wget http://location.to/ssl-public-key.pem
    $ catfriend

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

## TODO
 * Support POP3/Atom/RSS
