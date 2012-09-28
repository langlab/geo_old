
module "App.Media", (exports,top)->

  class Model extends BB.Model
    syncName: 'media'

    progress: ->
      parseInt @get('progress'), 10

    thumbnailSrc: ->
      if @progress() < 100
        "http://lorempixel.com/400/300/abstract/2/PROCESSING%20VIDEO/"
      else
        "#{CFG.S3.URL_ROOT}#{CFG.S3.MEDIA_BUCKET}/#{@get('urlBase')}_0004.png"

    urlBase: ->
      "#{App.Utils.Encode.toHex @get('fpData').url}"


  class Collection extends BB.Collection
    syncName: 'media'
    model: Model

    dbEvent: (data)->
      {event, model, progress} = data
      if event is 'progress'
        m = @get(model._id)
        m.set 'progress', progress
        console.log 'updated: ',m


  class Router extends BB.Router

    initialize: (@options)->
      _.extend @, @options
      @data.media = new Collection

    routes:
      'media':'list'


    list: ->
      @clearViews()
      @views.list = new Views.List collection: @data.media
      @data.media.fetch {
        success: => @views.list.open()
      }

  
  Views = {}



  class Views.IconItem extends BB.View

    tagName: 'li'
    className: 'span3 media-icon-item'

    initialize: ->
      @model.on 'change:progress', @updateProgress

    events:
      'click .delete': -> @model.destroy()

    updateProgress: =>
      if @model.progress() < 100
        @$('.bar').css 'width', "#{@model.progress()}%"
      else
        @render()

    template: ->
      span class:'thumbnail', ->
        img src:"#{@model.thumbnailSrc()}"
        if @model.progress() < 100
          div class:'progress progress-striped active progress-warning', style:'height:10px', ->
            div class:'bar', style:"width: #{@model.progress()}%"
        div class:'caption', ->
          a href:"#media/#{@model.id}", "#{@model.get('title')}"
          span class:'icon-trash delete'



  class Views.List extends BB.View

    tagName: 'div'
    className: 'media-list'

    initialize: ->
      @collection.on 'reset', =>
        @render()

      @collection.on 'add', =>
        @render()

      @collection.on 'remove', =>
        @render()

    events:
      
      'click .upload-file': ->
        
        fpOptions =
          metadata: true

        filepicker.getFile '*/*', fpOptions, @createFromUpload

    createFromUpload: (url,data)=>
      title = prompt 'Please enter a name for your media:', data.filename

      @collection.create {
        fpData: data
        fpUrl: url
        title: title
      }, {
        wait: true
      }


    template: ->
      div class:'btn-group', ->
        button class:'btn upload-file', "upload file"

      ul class:'thumbnails', ->
        
            

    render: ->
      super()

      for media in @collection.models
        v = new Views.IconItem model: media
        v.render().open @$('.thumbnails')

      @

  _.extend exports, {
    Model: Model
    Collection: Collection
    Router: Router
    Views: Views
  }


  