request = require 'request-json-light'
log     = require('printit')
    prefix: 'filteredReplication'


module.exports =


    getFilterName: (deviceName) ->
        log.debug "getFilterName #{deviceName}"

        "filter-#{deviceName}-config"


    getDesignDocId: (deviceName) ->
        log.debug "getDesignDocId #{deviceName}"

        "_design/#{@getFilterName deviceName}"


    getFilteredFunction: (config) ->
        log.debug "getFilteredFunction"

        throw new Error 'No config' unless config?

        filters = []

        if config.contact?
            filters.push "doc.docType.toLowerCase() === 'contact'"

        if config.calendar?
            filters.push "doc.docType.toLowerCase() === 'event'"
            filters.push "doc.docType.toLowerCase() === 'tag'"

        if config.file?
            filters.push "doc.docType.toLowerCase() === 'file'"
            filters.push "doc.docType.toLowerCase() === 'folder'"

        if config.notification?
            filters.push """
            (doc.docType.toLowerCase() === 'notification'
                && doc.type === 'temporary')
            """

        "function (doc) { return doc.docType && (#{filters.join ' || '}); }"


    generateDesignDoc: (deviceName, config) ->
        log.debug "generateDesignDoc #{deviceName}"

        # create couch doc
        _id: @getDesignDocId deviceName
        views: {} # fix couchdb error when views is not here
        filters:
            "#{@getFilterName deviceName}": @getFilteredFunction config


    setDesignDoc: (cozyUrl, deviceName, password, config, callback) ->
        log.debug "setDesignDoc #{cozyUrl}, #{deviceName}"

        unless config.file or config.contact or config.calendar \
                or config.notification
            return callback new Error "What do you want to synchronize?"

        doc = @generateDesignDoc deviceName, config

        client = request.newClient cozyUrl
        client.setBasicAuth deviceName, password
        client.put "/ds-api/filters/config", doc, (err, res, body) ->
            callback err, body


    getDesignDoc: (cozyUrl, deviceName, password, callback) ->
        log.debug "getDesignDoc #{cozyUrl}, #{deviceName}"

        client = request.newClient cozyUrl
        client.setBasicAuth deviceName, password
        client.get "/ds-api/filters/config", (err, res, body) ->
            callback err, body
