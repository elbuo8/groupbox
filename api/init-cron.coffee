module.exports = (db) =>
    console.log 'init-cron'
    db.collection 'events', (error, collection) ->
        collection.find {start:{$lte: (new Date().getTime())/1000}, queued:{$nin: [true]}}, (error, cursor) ->
            try
                cursor.each(error, event) ->
                    if event
                        setTimeout (require './event-pool-creation'), 0, event, db
                        setTimeout (require './event-pool-remove'), 0, event, db
            catch e

            finally

    db.collection 'onGoingEvents', (error, collection) ->
        collection.remove {end:{$lte: (new Date().getTime())/1000}}, (error, result) ->
            console.log 'removed' + result
