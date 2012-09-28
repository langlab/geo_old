template = ->
  doctype 5
  html ->

    head ->

      meta charset:'utf-8'
      title "geolab"

      link rel:'stylesheet', type:'text/css', href:'/css/bootstrap.min'
      link rel:'stylesheet', type:'text/css', href:'/css/bootstrap-responsive.min'
      link rel:'stylesheet', type:'text/css', href:'/css/font-awesome'
      link rel:'stylesheet', type:'text/css', href:'/css/index'

    body ->
      
      

      div class:'top-nav-cont container', ->
      div class:'main-cont buffer-top container', ->

      script src:'/socket.io/socket.io.js'
      script src:'/js/ck'
      script src:'/js/vendor'
      script src:'/js/common'
      script type:'text/javascript', src:'//api.filepicker.io/v0/filepicker.js'
      script """
        window.CFG = #{JSON.stringify @CFG}
      """


module.exports = template
