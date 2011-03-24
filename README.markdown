# catfriend

catfriend is python script that checks your e-mail and creates desktop notifications using dbus.

## installation
    $ git clone git://github.com/tuxjay/catfriend.git
    $ cp catfriend/catfriend.sample.config ~/.config/catfriend
    $ ./catfriend/catfriend.py

## configuration
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

## dependencies
* python-notify
