###
Cron for deleting onGoingEvent
###

module.exports = (event, db) ->
    db.collection 'onGoingEvents', (error, collection) ->
        collection.remove {_id: event._id}, (error, result) ->
            if error
                console.log error