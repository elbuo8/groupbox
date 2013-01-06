dbox = require 'dbox'
app = dbox.app {'app_key': process.env.DBOX_APP_KEY, 'app_secret': process.env.DBOX_SECRET_KEY}

###
Post Event Creation
###


#Error codes
# 0 - good
# 1 - user not registered
# 2 - fail adding event

###
Exmaple POST
{
	"uid" : "12421",
	"name" : "algo",
	"start" : "Date String: 12/12/2012 23:30 UTC-4, algo parecido",
	"end" : "Como el de arriba",
	"folder" : "/groubox_text",
	"message" : "Lelolelo",
	"socials" : {
					"Facebook" : true,
					"Twitter" : true,
					"Instagram" : false
				}
}
###

module.exports = (req, res) ->
    #check if user is in db
    @db.collection 'users', (error, collection) ->
        collection.findOne {uid:req.body.uid}, (error, user) ->
            if not user #not registered
                res.send '1'
            else #add event to db
                #Event needs specific keys for Auth
                req.body.key = user.key
                req.body.secret = user.secret
                if (req.body.twitter is true)
                    req.body.twitter = user.twitter
                if (req.body.facebook is true)
                    req.body.facebook = user.facebook
                @db.collection 'events', (error, collection) ->
                    collection.insert req.body, (error, result) ->
                        if not error
                            res.send '{\'eventID\':' + result[0]._id + '}'
                            #Get initial cursor
	                        dropbox = app.client {'oauth_token': result.key, 'oauth_token_secret': result.secret}
	                        delta = (status, reply) ->
                                if reply.has_more
                                    dropbox.delta {'cursor': reply.cursor}, delta
                                else
                                    collection.update {_id:result._id}, {$set:{cursor: reply.cursor}}, (error, result) ->
                                        
                            dropbox.delta delta
                            #callback, delay in ms, parameters
                            #creates de cron job based on a timer
                            setTimeout (require './event-pool-creation'), (req.body.start*1000) - new Date().getTime(), result[0], @db
                            setTimeout (require './event-pool-remove'), (req.body.end*1000) - new Date().getTime(), result[0], @db
                        else
                            res.send '2'
