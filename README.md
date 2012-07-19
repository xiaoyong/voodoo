Voodoo -- Search PICB
=====================

Voodoo is a web application that can help you locate files by name and save you
from the hell of `find` when the target directory is fairly large. It is
specifically serving some privately shared directories in PICB, but you can
easily extend and apply it to any system.

Features
--------

*   Search by file category
*   Multiple target directories support
*   Case sensitive/insensitive setting
*   Regular expression support

Technical Details
-----------------

### Back End

The database used is powered by [mlocate](https://fedorahosted.org/mlocate/),
which is shipped in most Linux distributions (e.g. Arch Linux, Debian, RHEL,
Ubuntu). It periodically maintains a directory tree database which is used to
`locate` files efficiently. In the same way, the database used by Voodoo is
produced using `updatedb` coming within mlocate. It is updated daily as a cron
job.

### Front End

The web server side scripting was previously in [Perl CGI](bin/voodoo.pl). Now
it is moved to [Sinatra](http://www.sinatrarb.com/) in Ruby.
[jQuery](http://jquery.com/) is used to facilitate client side scripting.

### Deployment

Voodoo is currently running on [OpenShift](http://openshift.redhat.com/)
developed by Redhat Inc. Go to http://voodoo.xiaoyong.org/ for a glimpse.
