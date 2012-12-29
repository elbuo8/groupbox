###
Cron job to add the event to the event pool
###


module.exports = (event, db) ->
    #flag el event como upcommint
    #add it to upcomming pool
    db.collection 'onGoingEvents', (error, collection) ->
        collection.insert event, (error, result) ->
            if not error
                db.collection 'events', (error, collection) ->
                    collection.update {_id:event._id}, {$set:{queued:true}}, (error) ->
                        if error
                            console.log error
            else
                console.log 'event not added to pool' + JSON.stringify(event)
        
            