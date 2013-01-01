###
URL Params - uid, eventID
###



module.exports = (req, res) ->
    @db.collection 'events', (error, collection) ->
        collection.findOne {_id:req.query.eventID, uid:req.query.uid}, (error, event) ->
            if event
                collection.update {_id:req.query.eventID}, {$set:{cancelled:true}}, (error, result) ->
                    if (event.start*1000 > new Date().getTime()) #ya abia empezado
                        @db.collection 'onGoingEvents', (error, collection) ->
                            collection.remove {_id:req.query.eventID}, (error, result) ->
                                if error
                                    console.log error