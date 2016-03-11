should = require 'should'
sinon = require 'sinon'
FilterManager = require '../../src/filter_manager'

cozyUrl = 'http://localhost'
deviceName = 'local-device'
password = 'password'

describe "FilterManager", ->

    beforeEach ->
        @filterManager = new FilterManager cozyUrl, deviceName, password
        @mock = sinon.stub(@filterManager.http, 'put').yields null

    it "returns a doc id when getDocId() is call.", ->

        @filterManager.getDocId().should.equal \
            '_design/filter-local-device-config'

    it "returns a filter name when getFilterName() is call.", ->

        @filterManager.getFilterName().should.equal \
            'filter-local-device-config/config'

    it "returns an error if the configuration is empty", (done) ->

        @filterManager.createOrUpdate {}, (err) =>
            err.message.should.not.be.empty()
            should(err).be.null
            @filterManager.http.put.called.should.not.be.true()
            done()

    it "launch a request with good doc", (done) ->
        doc =
            _id: '_design/filter-local-device-config',
            filters:
                config: 'function (doc) { return doc.docType && (false || ' + \
                    'doc.docType.toLowerCase() === \'file\'); }'
            views: {}

        @filterManager.createOrUpdate {file: true}, (err) =>
            should(err).be.null
            @filterManager.http.put.called.should.be.true()
            @filterManager.http.put.getCall(0).args[1].toString() \
                .should.be.equal doc.toString()
            done()

    it "launch a request with good doc with another configuration", (done) ->
        doc =
            _id: '_design/filter-local-device-config',
            filters:
                config: 'function (doc) { return doc.docType && (false || ' + \
                    'doc.docType.toLowerCase() === \'file\' || ' + \
                    'doc.docType.toLowerCase() === \'folder\'); }'
            views: {}

        @filterManager.createOrUpdate {file: true, folder: true}, (err) =>
            should(err).be.null
            @filterManager.http.put.called.should.be.true()
            @filterManager.http.put.getCall(0).args[1].toString() \
                .should.be.equal doc.toString()
            done()
