fb = require 'fbgraph'

auth = fb.getOauthUrl {
    "client_id": process.env.FACEBOOK_APP_ID,
    "redirect_uri": 'http://groupbox.herokuapp.com/api/facebook-callback'
}

module.exports = (req, res) ->
    req.session.uid = req.query.uid
    res.redirect auth + '&scope=publish_stream'