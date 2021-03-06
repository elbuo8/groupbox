###
URL Params - uid, eventID
###

ObjectId = (require 'mongodb').ObjectID

module.exports = (req, res) ->
    @db.collection 'events', (error, collection) ->
        collection.findOne {_id: new ObjectId(req.query.eventID), uid:parseInt(req.query.uid, 10)}, (error, event) ->
            if event
                collection.update {_id: new ObjectId(req.query.eventID)}, {$set:{cancelled:true}}, (error, result) ->
                    res.send '{status: 0}'
                    if (event.start*1000 > new Date().getTime()) #ya abia empezado
                        @db.collection 'onGoingEvents', (error, collection) ->
                            collection.remove {_id: new ObjectId(req.query.eventID)}, (error, result) ->
                                if error
                                    console.log error
            else
                res.send '{status: 1}'