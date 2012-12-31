async = require 'async'
dbox = require 'dbox'
app = dbox.app {"app_key": process.env.DBOX_APP_KEY, "app_secret": process.env.DBOX_SECRET_KEY}
twitter = require 'node-twitter'
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
                            async.filter dbReply.entries, (entry, callback) =>
                                if ((entry[0].indexOf(event.folder) > -1) and (entry[1]))
                                    if (entry[1].mime_type)
                                        if (entry[1].mime_type.indexOf('image') > -1)
                                            callback(true)
                                        else
                                            callback(false)
                                    else
                                        callback(false)
                                else 
                                    callback(false)
                            , (photos) =>
                                async.forEach photos, (photo) =>
                                    ###
                                    If none of the social medias are active, pichear.
                                    Bajar las fotos. Save them to /tmp
                                    Check el active event. 
                                    Push them to selected api
                                    ###
                                    if (photo.length > 0)
                                        if (event.twitter or event.facebook or event.gplus)
                                            dropbox.shares photo[0], (status, link) ->
                                                console.log status
                                                console.log link
                                                console.log "step1"
                                                if (event.twitter)
                                                    console.log process.env.TWITTER_CONSUMER_KEY + " " + process.env.TWITTER_CONSUMER_SECRET,
                                                    console.log event.twitter.access_token + " " + event.twitter.access_secret
                                                    twitterClient = new twitter.RestClient process.env.TWITTER_CONSUMER_KEY,
                                                    process.env.TWITTER_CONSUMER_SECRET,
                                                    event.twitter.access_token,
                                                    event.twitter.access_secret
                                        
                                                    twitterClient.statusesUpdateWithMedia {'status': event.message, 'media[]': link}, (error, result) ->
                                                        console.log result
                                , (error) =>
                                    console.log error