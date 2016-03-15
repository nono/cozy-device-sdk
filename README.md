[Cozy][0] Device SDK
====================

[![Build Status][5]][6]

This node package will help development with:

 - [ ] authenticate to a cozy
 - [ ] create a device on cozy
 - [ ] remove a device on cozy
 - [X] create or update a filter for couch replication/changes feed:
   [see documentation](doc/filter_manager.md)
 - [ ] remove a filter


Commands
--------

* `npm install`: install dependencies
* `npm run build`: compile library to cozy-device-sdk.js
* `npm run lint`: launch coffeelint on all coffee source files
* `npm run test`: launch unit test with `mocha`


License
-------

Cozy Device SDK is developed by Cozy Cloud and distributed under the MIT
license.


What is Cozy?
-------------

![Cozy Logo][1]

[Cozy][0] is a platform that brings all your web services in the same private
space.  With it, your web apps and your devices can share data easily,
providing you with a new experience. You can install Cozy on your own hardware
where no one profiles you.


Community
---------

You can reach the Cozy Community by:

* Chatting with us on IRC #cozycloud on irc.freenode.net
* Posting on our [Forum][2]
* Posting issues on the [Github repos][3]
* Mentioning us on [Twitter][4]


[0]:  https://cozy.io
[1]:  https://raw.github.com/cozy/cozy-setup/gh-pages/assets/images/happycloud.png
[2]:  https://forum.cozy.io
[3]:  https://github.com/cozy/
[4]:  https://twitter.com/mycozycloud
[5]:  https://travis-ci.org/cozy/cozy-device-sdk.svg?branch=master
[6]:  https://travis-ci.org/cozy/cozy-device-sdk
