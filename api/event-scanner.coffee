async = require 'async'
dbox = require 'dbox'
app = dbox.app {"app_key": process.env.DBOX_APP_KEY, "app_secret": process.env.DBOX_SECRET_KEY}
###
Scan the onGoingEvents Pool and check for changes in the dropbox folder
###

###
Media handler.
1. Must check that file is in the correct folder.
2. Download photo, to localhost and submit it to social networks (Module)
###

mediaHandler = (folder) ->
    (entry) ->
        console.log folder
        console.log entry
        ###
        if entry[0].indexOf(folder) > -1
            console.log "in folder"
        ###

module.exports = (db) ->
    db.collection 'onGoingEvents', (error, collection) ->
        collection.find {}, (error, cursor) ->
            cursor.each (error, event) ->
                if event 
                    dropbox = app.client {"oauth_token": event.key, "oauth_token_secret": event.secret}
                    dropbox.delta {"cursor": event.cursor}, (status, dbReply) ->
                        # Navigate response
                        async.forEach dbReply.entries, mediaHandler(event.folder), (error) ->
                            console.log error 
                        collection.update {_id:event._id}, {$set:{cursor: dbReply.cursor}}, (error, result) ->