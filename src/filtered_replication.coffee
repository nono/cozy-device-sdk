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


    getDesignDoc: (deviceName, config) ->
        log.debug "getDesignDoc"

        # create couch doc
        _id: @getDesignDocId deviceName
        views: {} # fix couchdb error when views is not here
        filters:
            "#{@getFilterName deviceName}": @getFilteredFunction config


    setDesignDoc: (cozyUrl, deviceName, password, config, callback) ->
        log.debug "setDesignDoc"

        unless config.file or config.folder or config.contact \
                or config.calendar or config.notification
            return callback new Error "You want synchronise something?"

        doc = @getDesignDoc deviceName, config

        client = request.newClient cozyUrl
        client.setBasicAuth deviceName, password
        client.put "/ds-api/filters/config", doc, callback
