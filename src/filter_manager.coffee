request = require 'request-json-light'
log     = require('printit')
    prefix: 'FilterManager'

###*
 * FilterManager allows to create a filter specific by device and
 * get this filter to replicate couchdb with it to reduce consumption data.
 *
 * @class FilterManager
 * @see https://git.io/vzcCL filters.coffee controller in data-system
###
class FilterManager

    ###*
     * Create a FilterManager.
     *
     * @param {String} cozyUrl - it's url
     * @param {String} deviceName - it's device name equal to the login
     * @param {String} password - it's password for authentication
    ###
    constructor: (cozyUrl, @deviceName, password) ->
        @http = request.newClient cozyUrl
        @http.setBasicAuth @deviceName, password

    ###*
     * Create or update a filter for a specific configuration.
     *
     * @param {Object} config - Synchronize configuration:
     *   {
     *     file: {Boolean},
     *     folder: {Boolean},
     *     contact: {Boolean},
     *     calendar: {Boolean},
     *     notification: {Boolean},
     *   }
    ###
    createOrUpdate: (config, callback) ->
        log.debug "createOrUpdate"

        unless config.file or config.folder or config.contact \
                or config.calendar or config.notification
            return callback new Error "You want synchronise something?"

        # create filter function
        filter = "false"

        for param in ['file', 'folder', 'contact']
            if config[param]
                filter += " || doc.docType.toLowerCase() === '#{param}'"

        if config.calendar?
            filter += " || doc.docType.toLowerCase() === 'event'"
            filter += " || doc.docType.toLowerCase() === 'tag'"

        if config.notification?
            filter += " || (doc.docType.toLowerCase() === 'notification'"
            filter += " && doc.type === 'temporary')"

        # create couch doc
        doc =
            _id: @getDocId()
            views: {} # fix couchdb error when views is not here
            filters:
                config: "function (doc) { return doc.docType && (#{filter}); }"

        @http.put "/ds-api/filters/config", doc, callback

    ###*
     * Get the design docId of the filter this device.
     *
     * @return {String}
    ###
    getDocId: ->
        log.debug "getDocId"

        "_design/#{@_getFilterDocName()}"

    ###*
     * Get filter name for this device.
     *
     * @return {String}
    ###
    getFilterName: ->
        log.debug "getFilterName"

        "#{@_getFilterDocName()}/config"


    _getFilterDocName: ->
        "filter-#{@deviceName}-config"


module.exports = FilterManager
