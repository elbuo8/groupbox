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
 

module.exports = (db) ->
    db.collection 'onGoingEvents', (error, collection) ->
        collection.find {}, (error, cursor) ->
            cursor.each (error, event) ->
                if event 
                    dropbox = app.client {"oauth_token": event.key, "oauth_token_secret": event.secret}
                    dropbox.delta {"cursor": event.cursor}, (status, dbReply) ->
                        collection.update {_id:event._id}, {$set:{cursor: dbReply.cursor}}, (error, result) ->
                            
                        # Navigate response
                        if (dbReply.entries.length > 0)
                            async.forEach dbReply.entries, (entry) =>
                                # Verify that it's on the folder and that its an image
                                if ((entry[0].indexOf event.folder > -1) and (entry[1].mime_type.indexOf('image') > -1))
                                     console.log entry[0]
                            , (error) ->
                                if error
                                    console.log error 
                        