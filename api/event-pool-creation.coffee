###
Cron job to add the event to the event pool
###

SG = (require 'sendgrid').SendGrid
sendgrid = new SG process.env.SENDGRID_USERNAME, process.env.SENDGRID_PASSWORD
dbox = require 'dbox'
app = dbox.app {'app_key': process.env.DBOX_APP_KEY, 'app_secret': process.env.DBOX_SECRET_KEY}

module.exports = (event, db) ->
    #flag el event como upcomming
    #add it to upcomming pool
    db.collection 'events', (error, collection) ->
        collection.findOne {_id: event._id}, (error, currentEvent) ->
            console.log 'adding event'
            console.log !(currentEvent.cancelled?)
            if !(currentEvent.cancelled?)
                db.collection 'onGoingEvents', (error, collection) ->
                    collection.insert event, (error, result) ->
                        if not error
                            db.collection 'events', (error, collection) ->
                                collection.update {_id: event._id}, {$set:{queued:true}}, (error) ->
                                    if error
                                        console.log error
                            dropbox = app.client {'oauth_token': event.key, 'oauth_token_secret': event.secret}
                            dropbox.account (status, account) ->
                                sendgrid.send {to: account.email, from: 'yamil.asusta@upr.edu', subject: 'We have your back on ' + event.name, text: 'Feel free to take your pictures!'}, (success, message) ->
                                    
                        else
                            console.log 'event not added to pool' + JSON.stringify(event)
        

