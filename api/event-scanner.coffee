dbox = require 'dbox'

###
Scan the onGoingEvents Pool and check for changes in the dropbox folder
###


module.exports = (db) ->
    db.collection 'onGoingEvents', (error, collection) ->
        collection.find {}, (error, cursor) -> #get all active events
            cursor.each (error, event) ->
                parseToken = dbox.app {"app_key", event.key, "app_secret":event.secret}
                dropbox = parseToken.client event.dropboxToken
                dropbox.delta (status, reply) ->
                    console.log reply
            
