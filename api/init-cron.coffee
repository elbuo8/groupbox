

module.exports = (db) ->
    db.collection 'events', (error, collection) ->
        collection.find {start:{$gte: new Date().getTime()/1000}}, (error, cursor) ->
            cursor.each(error, event) ->
                if (event.queued is undefined or event.queued is null)
                    setTimeout (require './event-pool-creation'), 0, event, @db
                    setTimeout (require './event-pool-remove'), 0, event, @db

    db.collection 'onGoingEvents', (error, collection) ->
        collection.remove {end:{$gte: (new Date().getTime())/1000}}, (error, result) ->
