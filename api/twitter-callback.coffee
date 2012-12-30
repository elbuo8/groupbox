OAuth = (require 'oauth').OAuth

oa = new OAuth "https://api.twitter.com/oauth/request_token",
    "https://api.twitter.com/oauth/access_token",
    process.env.TWITTER_CONSUMER_KEY,
    process.env.TWITTER_CONSUMER_SECRET,
    "1.0",
    "http://groupbox.herokuapp.com/api/auth-twitter-callback",
    "HMAC-SHA1"

module.exports = (req, res) ->
    if (req.session.oauth)
        cacheAuth = req.session
        oa.getOAuthAccessToken cacheAuth.token, cacheAuth.token_secret, req.query.oauth_verifier, (error, oauth_access_token, oauth_access_token_secret, results) ->
            console.log arguments
            