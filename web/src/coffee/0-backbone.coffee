
# BB
# extensions / modifications to Backbone classes


module "BB", (exports,top)->

  socketSync = (method,model,options)->
    console.log 'emitting sync: ',model.syncName, method, model, options
    window.sock.emit 'api', model.syncName, {
      method: method
      model: model
      options: options
    }, (err, response)->
      console.log err,response
      if err then options.error response
      else options.success response


  class Model extends Backbone.Model
    idAttribute: '_id'

  class Collection extends Backbone.Collection
    
    getByIds: (ids)->
      @filter (m)-> m.id in ids

  Model::sync = Collection::sync = socketSync

  class View extends Backbone.View

    open: (cont = '.main-cont')->
      @$el.appendTo cont
      @trigger 'open', cont
      @isOpen = true
      @

    close: ->
      @unbind()
      @remove()
      @trigger 'close'
      @isOpen = false
      @

    render: ->
      @$el.html ck.render @template, @
      @

  class Router extends Backbone.Router

    clearViews: (exceptFor)->
      if not _.isArray exceptFor then exceptFor = [exceptFor]
      view.close() for key,view of @views when not (key in exceptFor)
      

  _.extend exports, {
    Model: Model
    Collection: Collection
    View: View
    Router: Router
  }