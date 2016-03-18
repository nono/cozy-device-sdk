request = require 'request-json-light'
log     = require('printit')
    prefix: 'filteredReplication'


module.exports =


    getFilterName: (deviceName) ->
        log.debug "getFilterName"

        "filter-#{deviceName}-config"


    getDesignDocId: (deviceName) ->
        log.debug "getDesignDocId"

        "_design/#{@getFilterName deviceName}"


    getFilteredFunction: (config) ->
        log.debug "getFilteredFunction"

        filter = "false"

        if config?.contact?
            filter += " || doc.docType.toLowerCase() === 'contact'"

        if config?.calendar?
            filter += " || doc.docType.toLowerCase() === 'event'"
            filter += " || doc.docType.toLowerCase() === 'tag'"

        if config?.file?
            filter += " || doc.docType.toLowerCase() === 'file'"
            filter += " || doc.docType.toLowerCase() === 'folder'"

        if config?.notification?
            filter += " || (doc.docType.toLowerCase() === 'notification'"
            filter += " && doc.type === 'temporary')"

        "function (doc) { return doc.docType && (#{filter}); }"


    generateDesignDoc: (deviceName, config) ->
        log.debug "generateDesignDoc"

        # create couch doc
        _id: @getDesignDocId deviceName
        views: {} # fix couchdb error when views is not here
        filters:
            "#{@getFilterName deviceName}": @getFilteredFunction config


    setDesignDoc: (cozyUrl, deviceName, password, config, callback) ->
        log.debug "setDesignDoc"

        unless config.file or config.contact or config.calendar \
                or config.notification
            return callback new Error "What do you want to synchronize?"

        doc = @generateDesignDoc deviceName, config

        client = request.newClient cozyUrl
        client.setBasicAuth deviceName, password
        client.put "/ds-api/filters/config", doc, callback


    getDesignDoc: (cozyUrl, deviceName, password, callback) ->
        log.debug "getDesignDoc"

        client = request.newClient cozyUrl
        client.setBasicAuth deviceName, password
        client.get "/ds-api/filters/config", (err, res, doc) ->
            callback err, doc
