
module "BB.UI", (exports, top)->
  
  class State extends BB.Model

  Views = {}
  
  class Views.Tags extends BB.View
    tagName: 'div'
    className: 'ui-tags'

    initialize: (@options = {})->

      _.defaults @options, {
        tags: []
        typeahead: ['one','two','three','four']
      }

      @reset @options.tags

    tagsTemplate: ->
      span class:'icon-tags pull-left'
      # console.log @_tags, @getArray(),@getString()
      for tag in @getArray()
        span '.tag', tag

    renderTags: ->
      @$('.ui-tags-cont').html ck.render @tagsTemplate, @

    template: ->
      span class:'ui-tags-cont tags-list', ->

      span class:'ui-tag-entry', ->
        input type:'text', class:'tag-input input-small', 'data-provide':'typeahead', placeholder:'+ tag'


    isValidTag: (tag)->
      not (tag in @_tags) and (tag.trim() isnt '')

    events: ->
      'keydown input': (e)->
        if e.which in [9,13,188]
          e.preventDefault()
          if @isValidTag((val = $(e.currentTarget).val().trim()))
            @addTag val

        if e.which in [8,46]
          if $(e.currentTarget).val() is ''
            e.preventDefault()
            @removeLastTag()
      'change input': (e)->
        if @isValidTag((val = $(e.currentTarget).val().trim()))
          @addTag $(e.currentTarget).val()

    addTag: (tag)->
      @_tags.push tag
      @renderTags()
      @trigger 'change', @getArray(), @getString()
      @$('input').val('').focus()
      @

    removeLastTag: ->
      removedTag = @_tags.pop()
      @renderTags()
      @trigger 'change', @getArray(), @getString()
      @$('input').val('').focus()
      @


    getArray: ->
      @_tags

    getString: ->
      @_tags.join '|'

    reset: (tags)->
      if _.isString tags then @_tags = (if tags is "" then [] else ((tags.split '|') ? []))
      if _.isArray tags then @_tags = tags ? []

    render: ->
      @$el.html ck.render @template, @
      @$('input').typeahead {
        source: @options.typeahead
      }
      @renderTags()
      @



  class Views.Loading extends BB.View
    className:'loading-view'
    tagName:'div'

    initialize: (@options={})->
      _.defaults @options, {
        loadingText: 'Loading...'
      }
      console.log @options.loadingText
      @on 'open', =>
        @$('.view-cont').center()

    template: ->
      div class:'view-cont', ->
        div class:'spinner-cont'
        h2 class:'loading-text', @loadingText

    render: ->
      @$el.html ck.render @template, @options
      @spinner = new Spinner({top:'0px', left:'0px'}).spin(@$('.spinner-cont')[0])
      @

    close: ->
      @$el.fadeOut 'fast', =>
        @spinner.stop()
        super()


  _.extend exports, {
    State: State
    Views: Views
  }