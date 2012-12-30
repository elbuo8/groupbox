OAuth = (require 'oauth').OAuth

oa = new OAuth "https://api.twitter.com/oauth/request_token",
    "https://api.twitter.com/oauth/access_token",
    process.env.TWITTER_CONSUMER_KEY,
    process.env.TWITTER_CONSUMER_SECRET,
    "1.0",
    "http://groupbox.herokuapp.com/api/auth-twitter-callback",
    "HMAC-SHA1"

module.exports = (req, res) ->
    oa.getOAuthRequestToken (error, oauth_token, oauth_token_secret, results) ->
        req.session.token = oauth_token
        req.session.token_secret = oauth_token_secret
        res.redirect 'https://twitter.com/oauth/authenticate?oauth_token=' + oauth_token