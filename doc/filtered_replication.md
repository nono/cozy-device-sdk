Filtered Replication/Changes
============================

The pouchdb documentation is really good to understand it:

 * [API for filtered replication][1]
 * [API for filtered changes][2]
 * [Blog post for filtered replication][3]

The goal is to filter couch docs in remote not in local device.


Configuration
-------------

The configuration allow you what you want synchronize:

```javascript
config = {
    file: true,
    contact: true,
    calendar: true,
    notification: true,
}
```


Create a filtered doc
---------------------

To create a filteredReplication you must have:

 * a cozy URL: `https://demo.cozycloud.cc`
 * an device name, it's the login for authentication': `demo-laptop`
 * a password for authentication: `********`
 * a configuration
 * a callback

```javascript
config = {file: true, folder: true}
cozyUrl = 'https://demo.cozycloud.cc'
deviceName = 'demo-laptop'
password = '********'
filteredReplication.setDesignDoc(cozyUrl, deviceName, password, config, callback);
```

Commands
--------

 * To get filter name: `filteredReplication.getFilterName(deviceName)`
 * To get design doc id: `filteredReplication.getDesignDocId(deviceName)`
 * To get filtered function: `filteredReplication.getFilteredFunction(config)`
 * To get design doc: `filteredReplication.getDesignDoc(deviceName, config)`


[1]:  https://pouchdb.com/api.html#filtered-replication
[2]:  https://pouchdb.com/api.html#filtered-changes
[3]:  https://pouchdb.com/2015/04/05/filtered-replication.html
