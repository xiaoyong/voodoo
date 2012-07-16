Sinatra on OpenShift
====================

This git repository helps you get up and running quickly w/ a Sinatra installation
on OpenShift.


Running on OpenShift
----------------------------

Create an account at http://openshift.redhat.com/

Create a ruby-1.8 application

    rhc app create -a sinatra -t ruby-1.8

Add this upstream sinatra repo

    cd sinatra
    git remote add upstream -m master git://github.com/openshift/sinatra-example.git
    git pull -s recursive -X theirs upstream master
    
Then push the repo upstream

    git push

That's it, you can now checkout your application at:

    http://sinatra-$yournamespace.rhcloud.com

