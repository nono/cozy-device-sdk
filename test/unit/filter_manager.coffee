should = require 'should'
FilterManager = require '../../src/filter_manager'

cozyUrl = 'http://localhost'
deviceName = 'local-device'
password = 'password'
filterManager = new FilterManager cozyUrl, deviceName, password

describe "FilterManager", ->

    it "returns a doc id when getDocId() is call.", ->

        filterManager.getDocId().should.equal \
            '_design/filter-local-device-config'

    it "returns a filter name when getFilterName() is call.", ->

        filterManager.getFilterName().should.equal \
            'filter-local-device-config/config'

    it "returns an error if the configuration is empty", (done) ->

        filterManager.createOrUpdate {}, (err) ->
            err.message.should.not.be.empty()
            done()

    it "returns an empty error", (done) ->

        filterManager.createOrUpdate {file: true}, (err) ->
            err.should.be.empty()
            done()
