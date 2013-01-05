async = require 'async'
dbox = require 'dbox'
app = dbox.app {"app_key": process.env.DBOX_APP_KEY, "app_secret": process.env.DBOX_SECRET_KEY}
twitter = require 'node-twitter'
fs = require 'fs'
crypto = require 'crypto'
formData = require 'form-data'
https = require 'https'

###
Scan the onGoingEvents Pool and check for changes in the dropbox folder
###

###
Media handler.
1. Must check that file is in the correct folder.
2. Download photo, to localhost and submit it to social networks (Module)
###
 

module.exports = (db) ->
    console.log 'scanning'
    db.collection 'onGoingEvents', (error, collection) ->
        collection.find {}, (error, cursor) ->
            cursor.each (error, event) ->
                if event 
                    dropbox = app.client {'oauth_token': event.key, 'oauth_token_secret': event.secret}
                    dropbox.delta {'cursor': event.cursor}, (status, dbReply) ->
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
                                async.forEach photos, (photo, callback) =>
                                    ###
                                    If none of the social medias are active, pichear.
                                    Bajar las fotos. Save them to /tmp
                                    Check el active event. 
                                    Push them to selected api
                                    delete them
                                    ###
                                    if (photo.length > 0)
                                        if ((event.twitter or event.facebook or event.gplus) and (new Date(photo[1].modified)).getTime() > event.start*1000)
                                            dropbox.get photo[0], {root:'dropbox'}, (status, buffer, metadata) =>
                                                #Pull local to /tmp
                                                hash = ((crypto.createHash('sha1')).update(photo[0])).digest('hex')
                                                ext = photo[0].substring(photo[0].lastIndexOf('.'))
                                                fs.writeFile '/tmp/' + hash + ext, buffer, (error) ->
                                                    if error
                                                        callback(error)
                                                    else
                                                        if (event.twitter)
                                                            twitterClient = new twitter.RestClient process.env.TWITTER_CONSUMER_KEY,
                                                            process.env.TWITTER_CONSUMER_SECRET,
                                                            event.twitter.access_token,
                                                            event.twitter.access_secret

                                                            twitterClient.statusesUpdateWithMedia {'status': event.message, 'media[]': '/tmp/' + hash + ext}, (error, result) ->
                                                        
                                                        if (event.facebook)
                                                            form = new formData()
                                                            form.append 'file', (fs.createReadStream ('/tmp/' + hash + ext))
                                                            form.append 'message', event.message
                                                            statusUpdate = {
                                                                method: 'post',
                                                                host: 'graph.facebook.com',
                                                                path: '/me/photos?access_token' + event.facebook.access_token,
                                                                headers: form.getHeaders()
                                                            }
                                                            form.pipe https.request statusUpdate, (res) =>
                                                                console.log res
                                                            
                                                        if (event.gplus)
                                                            console.log event.gplus
                                                        
                                , (error) =>
                                    #console.log error

                                                    