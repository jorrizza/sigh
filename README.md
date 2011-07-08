Sigh. A monitoring application.
===============================

Copyleft 2010 - Joris van Rooij <jorrizza@jrrzz.net>

> A sigh is an audible exhalation of air arising from tiredness
> or emotion, usually sadness, which itself could be stemming
> from feelings of sadness or futility. A sigh can also arise
> from positive emotions such as relief. Some people do it just
> to cool down organs or suppress emotions.
>  -- Wikipedia

Why call it this? I don't know. Sigh.

Sigh has been created to replace things like Munin and
eventually Nagios. These things don't scale that well. Not well
enough anyway. If you want to monitor hundreds of servers,
generating the graphs on a single machine after pulling the
measurements from every single box just doesn't make sense.

Why not turn things around? Machines push their data to a
central (very fast, distributed) data store, and a web server
supplies a simple interface to view the measurements. Graphs
can easily be created using HTML5 Canvas, so there's no need
to generate image files anymore.

The final component is a daemon that checks if the measurements
are within predefined bounds. If they exceed, it should notify
the proper authorities. (this part is still a todo)

Simple, isn't it?

Using:
* Ruby 1.9
* Redis
* jQuery and Flot
* Gems: sinatra, redis, daemons, eventmachine

Installation of Clients
-----------------------

There are two ways to install Sigh. The first way is the easy way.
Install sigh using Rubygems and make some changes to your system.

    gem install sigh
    mkdir -p /etc/sigh/collectors
    adduser sigh

Copy settings.yml to /etc/sigh and add your collectors to the collectors
directory. Make sure /usr/local/bin/sigh-collectord exists if you want to
use the supplied init script to start sigh at boot. A symlink will do.

The second way is to check out this repository and to add your collectors
to collectors_enabled. Use your own method of choice to start the collector
daemon.

Installation of Server
----------------------

Again, there are two ways to get this to work. You can install the gem and
run sigh-web. This will start the server (listening on port 4567). A more
flexible approach is to use this repository as a rack webapp. A rackup file
is added for convenience.

Adding Collectors
-----------------

Sigh has a simple yet effective DSL to write collectors.

A collector is a small Ruby script that collects the data from your host.
For everything you want to monitor (and which is describable as a floating
point number) you can create a collector. Sigh will run all your collectors
on the systems you put them on.

Here's an example of a collector that samples the load of a Linux machine:

    Sigh::Collector.collects do
      type 'system'
      name 'load'
      unit 'processes'
      upper_bound 8.00
      
      measure do
        File.read('/proc/loadavg').split[0].to_f
      end
    end

It's a system collector (collect systems statistics), called load, which
measures the amount of processes currently waiting in your scheduler queue.
When the measured value exceeds upper_bound, you'll be spammed. It's pretty
readable, isn't it?

Instead of supplying a static value to a configuration parameter, you can
also use a lambda to supply the data.

There's one configuration parameter called host. It's normally supplied by
your operating system (through Socket.gethostname), but I can imagine you
want to override that. In that case, just add host 'myhostname' to your
collector.

The collector supports several command line arguments:

* --dryrun Test the output of the collector.
* --monitor Read the measurements this collector has sent to the storage.
* [nothing] Run the collector for a single measurement. It's okay to use
  this for testing, but don't do this in production. 

You can run the collector using sigh-collector followed by the name of your
collector and, if needed, the command line argument. Be sure your collector
is located in the collectors_enabled or /etc/sigh/collectors directory.

Collector Daemon
----------------

The collector daemon is responsible for starting the collectors on a single
machine. It uses EventMachine to fire a series of short-lived child processes
that collect the system data using the collectors.

The daemon itself is controlled using Daemons, so you can easily start, stop
and monitor the collector daemon.

You can run the collector daemon using sigh-collectord. There's also an
init script that will start it for you at boot.

Notification Daemon
-------------------

Soon.