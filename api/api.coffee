io = require 'socket.io'
redis = require 'redis'
RedisStore = require 'socket.io/lib/stores/redis'
_ = require 'underscore'
util = require 'util'
Password = require './lib/password'

pub    = redis.createClient()
sub    = redis.createClient()
client = redis.createClient()

red = redis.createClient()

services =
  user: require './db/user'
  media: require './db/media'


module.exports = api = (server)->

  sio = io.listen server

  sio.set 'store', new RedisStore {
    redisPub : pub
    redisSub : sub
    redisClient : client
  }

  sio.configure ->

    sio.set 'authorization', (hs,cb)->

      cookies = hs.headers.cookie?.split(';')
      ssidStr = _.find cookies, (i)-> /express\.sid/.test(i)
      ssid = (unescape ssidStr?.split('=')[1])[2..25]

      console.log 'sessionId: ',ssid

      console.log 'getting session...'
      # find the session in redis
      red.get "sess:#{ssid}", (err, sessStr)->
        if sessStr
          hs.sess = JSON.parse sessStr
          hs.userId = hs.sess?.auth?.userId
          
        cb null, true



  # socket API
  sio.on 'connection', (client)->
    {role, userId} = client.handshake

    # keep track of the sockets by userId
    if userId
      console.log 'user joining self socket: ',userId
      client.join "self:#{userId}"

    client.on 'api', (schema, data, cb)->
      data.handshake = client.handshake
      { method, model, options, handshake } = data
      api = services[schema].api data, cb

    client.on 'handshake', (cb)->
      console.log 'handshake'
      cb null, client.handshake


  emitEventFunc = (schema) ->
    # send back a schema-specific event-emitting function that takes data
    # as a parameter

    (data)-> 
      { who, group } = data
      who = [ who ] unless _.isArray who
      for client in who
        sio.sockets.in("self:#{client}").emit 'api', schema, data

      if group
        sio.sockets.in("group:#{group}").emit 'api', schema, data

  for schema, service of services
    service.on 'event', emitEventFunc(schema)

  sio
      