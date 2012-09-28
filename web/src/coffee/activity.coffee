
module "App.Activity", (exports,top)->

  class Model extends BB.Model
    syncName: 'activity'

  class Collection extends BB.Collection
    syncName: 'activity'
    model: Model

  class Router extends BB.Router

  
  Views = {}

  class Views.Edit extends BB.View

    tagName: 'div'
    className: 'activity-detail row-fluid'

    template: ->
      div class:'span5 left-cont', ->
      div class:'span7 right-cont', ->



  _.extend exports, {
    Model: Model
    Collection: Collection
    Router: Router
    Views: Views
  }


  