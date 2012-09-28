
module "App", (exports,top)->

  class Model

    constructor: ->
      @loadingView = new BB.UI.Views.Loading
      @loadingView.render().open()

      window.filepicker?.setKey('Ag4e6fVtyRNWgXY2t3Dccz')
      # Stripe?.setPublishableKey('pk_04LnDZEuRgae5hqjKjFaWjFyTYFgs')

      @socketConnect()

      @data = {}
      @views = {}

      @connection.on 'connect', (data)=>
        console.log 'socket connected: ', data
        
        @connection.emit 'handshake', (err, @handshake)=>

          @routers =
            main: new Router { data: @data, views: @views }
            media: new App.Media.Router { data: @data, views: @views }

          Backbone.history.start() unless Backbone.History.started

          @loadingView.close()

        @connection.on 'api', (schema, data)=>
          @data[schema]?.dbEvent data
          

    socketConnect: ->
      @connection = window.sock = window.io.connect "/"
      @


  _.extend exports, {
    Router: Router
    Model: Model
    Views: Views = {}
  }


  class Router extends BB.Router

    initialize: (@options)->
      _.extend @, @options

    routes:
      '':'begin'

    begin: ->
      console.log 'begin'



$ ->
  window.app = new App.Model
  window.sock.on 'api', (schema, data)->
    console.log 'event from api: ',schema, data
  console.log 'ready!'