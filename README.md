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

## Copyright

Copyright 2008-2009 Best Practical Solutions. 
Distributed under the terms of the MIT License



[syncwithus]: http://syncwith.us
[prophet]:
[sd-doc]: http://syncwith.us
