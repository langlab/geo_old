mongoose = require 'mongoose'
mongoose.connect 'mongodb://localhost/lab'
_ = require 'underscore'
api = require './api'

{Schema} = mongoose
{ObjectId} = Schema

UserSchema = new Schema {
  created: type: Date, default: Date.now()
  lastLogin: type: Date, default: Date.now
  email: String
  name: String
  role: String
  twitter: {}
  twitterId: String
}


_.extend UserSchema.methods, {

  read: (data, cb)->
    cb null, @
}

_.extend UserSchema.statics, api.statics

_.extend UserSchema.statics, {


  read: (data, cb)->
    {model,options,handshake} = data
    {role,userId} = handshake

    if role is 'teacher'
      @findById userId, cb


  auth: (twitterData,cb)->
    @findOne { twitterId: twitterData.id }, (err, user)=>
      
      twitter =
        id: twitterData.id
        data: twitterData
        user: twitterData.screen_name
        name: twitterData.name
        img: twitterData.profile_image_url_https

      if user
        # update the user's twitter data
        user.twitter = twitter
        user.twitterId = twitter.id
        user.save (err)->
          cb err, user
      else
        # create a user and set the twitter data
        newUser = new @
        newUser.twitter = twitter
        newUser.twitterId = twitter.id
        newUser.save (err)->
          cb err, newUser

  self: (data,cb)->
    @findById data.handshake.userId, cb



}

module.exports = User = mongoose.model 'user', UserSchema