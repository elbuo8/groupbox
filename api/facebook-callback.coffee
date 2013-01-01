
fb = require 'fbgraph'

module.exports = (req, res) ->
    fb.authorize {'client_id': process.env.FACEBOOK_APP_ID,
    'redirect_uri': 'http://groupbox.herokuapp.com/api/facebook-callback',
    'client_secret': process.env.FACEBOOK_APP_SECRET,
    'code': req.query.code
    }, (error, facebookRes) ->
        console.log facebookRes