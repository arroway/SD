# SD version 0.75

SD is a peer-to-peer replicated distributed issue tracker.
http://syncwith.us[syncwithus]

## Installation

Noticeable Dependencies:

* Prophet[prophet]
~~~ sh
  $ git clone   
~~~ 

To get the latest version:
~~~ sh
  $ git clone   
~~~ 

SD v0.75 is also available on CPAN:
~~~ sh
  $ cpan 
~~~ 

## Help

~~~ sh
  $ sd help 
  $ sd <command> -h
~~~ 

## Examples of commands

A complete documentation is available on syncwith.us[sd-doc].

~~~ sh
  # Creates a repo
  $ sd init
 
  # Clones a distant database (replica)
  $ sd clone --from ''

  # Shows the tickets of the database (replica)
  $ sd ticket list
 
  # Displays the ticket number 42
  $ sd ticket show 42

  # Modifies a ticket with vim
  $ sd ticket update 42

  # Searches through all the componounts of all the tickets
  $ sd ticket search --regex abc

  # Closes a ticket and edits any property you want
  $ sd ticket resolve 42 --edit
  # or
  $ sd ticket close 42 -e

~~~ 

## Replicas

You can clone a distant bugtracker database that is not a SD repository
and create a "replica" of it that can sync thanks to a connector.

Available connectors: rt, trac, redmine, github, googlecode...

~~~ sh
  $ git clone --from "rt:http://my-rt-repo.com"; 
~~~

## About the OSLC-CM connector

The OSLC-CM connector aims at synchronizing databases from bugtrackers implementing
an Service Provider OSLC-CM connector. It allows SD to be, in the terms of OSLC-CM, 
a OSLC-CM Consumer.

The OSLC-CM connector uses the module Net-OSLC-CM[net::oslc::cm]. 
It has been tested with a Bugzilla Service Provider.

At this stage of development:

Feature:
* Cloning a bugtracker database available through a OSLC-CM Service Provider

Limitation:
* A global reseach using the commands `sd ticket list`  ou `sd ticket search` fails.
  Going the same, the home page of the server is empty.
  However, researches with a specified field work, as well as for tickets being created
  inside the cloned replica.
  Other commands seem to work correctly (create, update...)

~~~ sh
  $ git clone --from "oslccm:http//my-service-provider.com:port"; 
~~~


## Copyright

Copyright 2008-2009 Best Practical Solutions. 
Distributed under the terms of the MIT License



[syncwithus]: http://syncwith.us
[prophet]:
[sd-doc]: http://syncwith.us
[net::oslc::cm]: http://github.com/arroway/Net-OSLC-CM

