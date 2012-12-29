dbox = require 'dbox'
app = dbox.app {"app_key": process.env.DBOX_APP_KEY, "app_secret": process.env.DBOX_SECRET_KEY}
###
Scan the onGoingEvents Pool and check for changes in the dropbox folder
###


module.exports = (db) ->
    db.collection 'onGoingEvents', (error, collection) ->
        collection.find {}, (error, cursor) ->
            cursor.each (error, event) ->
                if event 
                    dropbox = app.client {"oauth_token": event.key, "oauth_token_secret": event.secret}
                    dropbox.delta {"cursor": event.cursor}, (status, reply) ->
                        console.log reply
                        collection.update {_id:event._id}, {$set:{cursor:reply.cursor}}, (error, result) ->
                    