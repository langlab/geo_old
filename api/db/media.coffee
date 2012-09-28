mongoose = require 'mongoose'
mongoose.connect 'mongodb://localhost/lab'
_ = require 'underscore'
api = require './api'

Zen = require '../lib/zen'


{Schema} = mongoose
{ObjectId} = Schema

User = require './user'

MediaSchema = new Schema {
  created: type: Date, default: Date.now()
  userId: type: ObjectId, ref: User
  
  fpData: {}
  fpUrl: String

  title: String
  urlBase: String

  progress: Number

}

MediaSchema.methods =
  
  isVideo: ->
    /video/.test @fpData.type

  encode: ->
    
  delete: (data,cb)->
    @remove (err)=>
      cb err, @


_.extend MediaSchema.statics, api.statics

_.extend MediaSchema.statics, {

  create: (data,cb)->
    {model,options,handshake:{userId}} = data

    newMedia = new @ model
    newMedia.userId = userId
    newMedia.urlBase = (new Buffer model.fpData.key).toString('hex')
    newMedia.save (err)=> 
      cb err, newMedia
      type = if newMedia.isVideo() then 'video' else 'audio'
      
      zen = new Zen newMedia
      
      zen.encode (job)=>
        console.log 'encoding job', job
      
      zen.on 'progress', (data)=>
        newMedia.progress = data.progress.progress
        newMedia.save (err)=>
          @emit 'event', {
            who: newMedia.userId
            event: 'progress',
            model: newMedia
            progress: data.progress.progress
          }


  read: (data,cb)->
    {model,options,handshake:{userId}} = data

    @find { userId: userId }, cb


}

module.exports = Media = mongoose.model 'media', MediaSchema