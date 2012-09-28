CFG = require '../conf'
express = require 'express'
everyauth = require 'everyauth'
RedisStore = require('connect-redis')(express)
store = new RedisStore()
app = express()
ck = require 'coffeekup'

User = require '../api/db/user'

everyauth.everymodule.userPkey '_id'

everyauth.everymodule.findUserById (userId, cb)->
  User.findById userId, cb

everyauth.twitter
  .consumerKey(CFG.TWITTER.CONSUMER_KEY)
  .consumerSecret(CFG.TWITTER.CONSUMER_SECRET)
  .callbackPath('/twitter/callback')
  .findOrCreateUser( (session, accessToken, accessTokenSecret, twitterData)->
    
    promise = @Promise()

    User.auth twitterData, (err,resp)->
      #console.log util.inspect resp
      if err
        promise.fail err
        return
      else
        console.log 'fulfilling promise'
        promise.fulfill resp

    return promise

  ).redirectPath('/')


templates =
  main: require './templates/main'

app.configure ->
  app.use express.cookieParser()
  app.use express.session {
    secret: 'keyboardCat'
    key: 'sessionId'
    cookie: { domain: '.langlab.org' }
    store: store
  }

  app.use everyauth.middleware()
  app.use express.bodyParser()


app.get '/', (req,res)->
  res.send ck.render templates.main, { CFG: CFG.CLIENT() }

app.get '/user', (req,res)->
  res.json {
    user: req.user
    session: req.session
    ssId: res.session?.id
  }

app.get '/js/:fn', (req,res)->
  {fn} = req.params
  res.sendfile "#{__dirname}/pub/js/#{fn}.js"

app.get '/css/:fn', (req,res)->
  {fn} = req.params
  res.sendfile "#{__dirname}/pub/css/#{fn}.css"

module.exports = app

