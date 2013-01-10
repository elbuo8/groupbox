dbox = require 'dbox'
app = dbox.app {'app_key': process.env.DBOX_APP_KEY, 'app_secret': process.env.DBOX_SECRET_KEY}
twitter = require 'node-twitter'
fb = require 'fbgraph'
async = require 'async'

module.exports = (req, res) ->
    @db.collection 'users', (error, collection) ->
        collection.findOne {uid: req.query.uid}, (error, user) ->
            async.parallel {
                twitter: (callback) ->
                    if (user.twitter)
                        twitterClient = new twitter.RestClient process.env.TWITTER_CONSUMER_KEY,
                        process.env.TWITTER_CONSUMER_SECRET,
                        event.twitter.access_token,
                        event.twitter.access_secret
                        
                        twitterClient.verifyCredentials (status) ->
                            console.log status
                            callback(null, status) 
                        
                , facebook: (callback) ->
                    if (user.facebook)
                        graph.setAccessToken user.facebook
                        graph.get 'me', (error, reply) ->
                            console.log arguments
                            callback(null, true)
                    else
                        callback(null, false)
                        
                        
                , dropbox: (callback) ->
                    dropbox = app.client {'oauth_token': user.key, 'oauth_token_secret': user.secret}
                    dropbox.account (status, reply) ->
                        if status.code is 200 then callback(null, true) else callback(null, true)
                    
                
                }, (error, response) ->
                res.send response
    
    