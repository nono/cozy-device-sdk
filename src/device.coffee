request = require 'request-json-light'
log     = require('printit')
    prefix: 'device'


# Some methods to discuss with a cozy stack
module.exports =

    # Pings the URL to check if it is a Cozy
    pingCozy: (cozyUrl, callback) ->
        log.debug "pingCozy #{cozyUrl}"

        client = request.newClient cozyUrl
        client.get "status", (err, res, body) ->
            if res?.statusCode isnt 200
                callback new Error "No cozy at this URL"
            else
                callback()


    # Pings the cozy to check the credentials without creating a device
    checkCredentials: (cozyUrl, password, callback) ->
        log.debug "checkCredentials #{cozyUrl}"

        client = request.newClient cozyUrl
        data =
            login: 'owner'
            password: password

        client.post "login", data, (err, res, body) ->
            if res?.statusCode isnt 200
                err = err?.message or body.error or body.message
            callback err


    # Register device remotely then returns credentials given by remote Cozy.
    # This credentials will allow the device to access to the Cozy database.
    registerDevice: (cozyUrl, deviceName, password, callback) ->
        log.debug "registerDevice #{cozyUrl}, #{deviceName}"

        client = request.newClient cozyUrl
        client.setBasicAuth 'owner', password

        client.post 'device/', {login: deviceName}, (err, res, body) ->
            if err
                callback err
            else if body.error?
                callback body.error
            else
                callback null,
                    id: body.id
                    password: body.password


    # Same as registerDevice, but it will try again of the device name is
    # already taken.
    registerDeviceSafe: (cozyUrl, deviceName, password, callback) ->
        log.debug "registerDeviceSafe #{cozyUrl}, #{deviceName}"

        tries = 1
        originalName = deviceName

        tryRegister = (name) ->
            module.exports.registerDevice cozyUrl, name, password, (err, res) ->
                if err is 'This name is already used'
                    tries++
                    tryRegister "#{originalName}-#{tries}"
                else
                    callback err, res

        tryRegister deviceName


    # Unregister device remotely, ask for revocation.
    unregisterDevice: (cozyUrl, deviceName, password, callback) ->
        log.debug "unregisterDevice #{cozyUrl}, #{deviceName}"

        client = request.newClient cozyUrl
        client.setBasicAuth deviceName, password

        client.del "device/#{deviceName}/", (err, res, body) ->
            if res.statusCode in [200, 204]
                callback null
            else if err
                callback err
            else if body.error?
                callback new Error body.error
            else
                callback new Error "Something went wrong (#{res.statusCode})"


    # Get useful information about the disk space
    # (total, used and left) on the remote Cozy
    getDiskSpace: (cozyUrl, login, password, callback) ->
        log.debug "getDiskSpace #{cozyUrl}, #{login}"

        client = request.newClient cozyUrl
        client.setBasicAuth login, password

        client.get "disk-space", (err, res, body) ->
            if err
                callback err
            else if body.error
                callback new Error body.error
            else
                callback null, body
