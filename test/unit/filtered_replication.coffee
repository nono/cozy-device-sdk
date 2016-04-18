should = require 'should'
sinon = require 'sinon'
filteredReplication = require '../../src/filtered_replication'

cozyUrl = 'http://localhost'
deviceName = 'local-device'
password = 'password'

describe "filteredReplication", ->

    describe "general", ->

        it "possible to get filter name from device name.", ->

            filteredReplication.getFilterName(deviceName).should.equal \
                'filter-local-device-config'

        it "possible to get design doc id from device name.", ->

            filteredReplication.getDesignDocId(deviceName).should.equal \
                '_design/filter-local-device-config'

        it "create design doc", ->

            config = file: true
            doc = filteredReplication.generateDesignDoc deviceName, config

            id = filteredReplication.getDesignDocId deviceName
            key = filteredReplication.getFilterName deviceName
            value = filteredReplication.getFilteredFunction config

            doc._id.should.be.equal id
            doc.views.should.be.empty()
            doc.filters.should.be.eql "#{key}": value

    describe "filtered function", ->

        it "throw an exception when called with an empty config", ->
            try
                filteredReplication.getFilteredFunction()
                fail()
            catch e
                e.message.should.equal 'No config'

        it "create contact filter function.", ->

            config = contact: true
            filteredFunction = filteredReplication.getFilteredFunction config
            fn = eval("(#{filteredFunction})")

            fn(docType: 'file').should.be.false()
            fn(docType: 'contact').should.be.true()

        it "create file and folder filter function.", ->

            config = file: true
            filteredFunction = filteredReplication.getFilteredFunction config
            fn = eval("(#{filteredFunction})")

            fn(docType: 'file').should.be.true()
            fn(docType: 'folder').should.be.true()
            fn(docType: 'contact').should.be.false()

        it "create calendar filter function.", ->

            config = calendar: true
            filteredFunction = filteredReplication.getFilteredFunction config
            fn = eval("(#{filteredFunction})")

            fn(docType: 'event').should.be.true()
            fn(docType: 'tag').should.be.true()
            fn(docType: 'contact').should.be.false()

        it "create notification filter function.", ->

            config = notification: true
            filteredFunction = filteredReplication.getFilteredFunction config
            fn = eval("(#{filteredFunction})")

            fn(docType: 'notification', type: 'temporary').should.be.true()
            fn(docType: 'contact').should.be.false()

        it "create filter function for all doc type.", ->

            config =
                file: true
                contact: true
                calendar: true
                notification: true
            filteredFunction = filteredReplication.getFilteredFunction config
            fn = eval("(#{filteredFunction})")

            # contact
            fn(docType: 'contact').should.be.true()
            # file
            fn(docType: 'file').should.be.true()
            fn(docType: 'folder').should.be.true()
            # calendar
            fn(docType: 'event').should.be.true()
            fn(docType: 'tag').should.be.true()
            # notification
            fn(docType: 'notification', type: 'temporary').should.be.true()
