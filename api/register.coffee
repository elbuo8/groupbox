dbox = require 'dbox'

###
POST Registration.
###
 
#Error codes
# 0 - good
# 1 - bad
###
dropboxAuth = (keys, res, collection) ->
    auth = dbox.app {"app_key": keys.key, "app_secret": key.secret}
    auth.requesttoken (status, token) ->
        res.send token
        auth.accesstoken token, (status, dropboxToken) ->
            console.log arguments
            collection.update {uid:keys.uid}, {$set{dropboxToken:dropboxToken}}
###

module.exports = (req, res) ->
    @db.collection 'users', (error, collection) ->
        collection.findOne {uid:req.body.uid}, (error, cursor) ->
            if cursor is null or cursor is undefined #Do not exist
                collection.insert req.body, {w:1}, (error, result) ->
                    if not error
                        res.send '0'
                    else
                        res.send '1'
            else
                collection.update {uid:req.body.uid}, {$set:{key:req.body.key, secret:req.body.secret}}, (error, result) ->
                    if not error 
                        res.send '0'
                    else
                        res.send '1'