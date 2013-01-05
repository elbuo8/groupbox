module.exports = (db) ->
    db.collection 'events', (error, collection) ->
        collection.find {start:{$gte: (new Date().getTime())/1000}, queued:{$nin: [true]}}, (error, cursor) ->
            if (cursor._events)
                cursor.each(error, event) ->
                    if (event)
                        setTimeout (require './event-pool-creation'), 0, event, db
                        setTimeout (require './event-pool-remove'), 0, event, db

    db.collection 'onGoingEvents', (error, collection) ->
        collection.remove {end:{$lte: (new Date().getTime())/1000}}, (error, result) ->
