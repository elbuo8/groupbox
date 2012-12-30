OAuth = (require 'oauth').OAuth

oa = new OAuth "https://api.twitter.com/oauth/request_token",
    "https://api.twitter.com/oauth/access_token",
    process.env.TWITTER_CONSUMER_KEY,
    process.env.TWITTER_CONSUMER_SECRET,
    "1.0",
    "http://groupbox.herokuapp.com/api/twitter-callback",
    "HMAC-SHA1"

module.exports = (req, res) ->
    cacheAuth = req.session
    oa.getOAuthAccessToken cacheAuth.token, cacheAuth.token_secret, req.query.oauth_verifier, (error, oauth_access_token, oauth_access_token_secret, results) ->     
        @db.collection 'users', (error, collection) ->
            collection.update {uid:req.session.uid}, {$set:{twitter:{access_token:oauth_access_token, access_secret:oauth_access_token_secret}}}, (error, result) ->
                res.redirect "groupbox://1/auth-ok?social=twitter&key="+oauth_access_token+"&secret="+oauth_access_token_secret            

