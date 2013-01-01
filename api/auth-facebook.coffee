fb = require 'fbgraph'

auth = fb.getOauthUrl {
    "client_id": process.env.FACEBOOK_APP_ID,
    "redirect_uri": 'http://groupbox.herokuapp.com/api/facebook-callback'
}

module.exports = (req, res) ->
    res.redirect auth