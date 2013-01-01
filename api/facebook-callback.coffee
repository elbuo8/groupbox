
fb = require 'fbgraph'

module.exports = (req, res) ->
    fb.authorize {'client_id': process.env.FACEBOOK_APP_ID,
    'redirect_uri': 'http://groupbox.herokuapp.com/api/facebook-callback',
    'client_secret': process.env.FACEBOOK_APP_SECRET,
    'code': req.query.code
    }, (error, facebookRes) ->
        @db.collection 'users', (error, collection) ->
            collection.findOne {uid:parseInt(req.session.uid, 10)}, (error, user) -> 
                if user
                    collection.update {uid:parseInt(req.session.uid, 10)}, {$set:{facebook:{access_token:facebookRes.access_token}}}, (error, result) ->
                res.redirect "groupbox://1/auth-ok?social=facebook&key="+facebookRes.access_token

        