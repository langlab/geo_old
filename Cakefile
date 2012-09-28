
require 'flour'
{spawn} = require 'child_process'
_ = require 'underscore'

wait = (someTime,thenDo) ->
  setTimeout thenDo, someTime
doEvery = (someTime,action)->
  setInterval action, someTime


task 'vendor', ->
  bundle 'web/src/js/*.js', 'web/pub/js/vendor.js'

task 'client',  ->

  bundle "web/src/coffee/*.coffee", 'web/pub/js/common.js'
  bundle "web/src/styl/*.styl", "web/pub/css/index.css"


# sync to dev server
task 'deploy', ->
  sync = spawn 'rsync', ['--delete','-avz',"#{__dirname}",'admin@langlab.org:~/dev/']
  sync.stdout.on 'data', (data)-> console.log "rsync: #{data}"
  sync.stderr.on 'data', (data)-> console.log "rsync: #{data}"


task 'dev', ->
  
  invoke 'vendor'
  invoke 'client'
  
  watch 'web/src/', ->
    invoke 'vendor'
    invoke 'client'


  watch 'api', -> invoke 'deploy'
  watch 'web', -> invoke 'deploy'
  watch 'geo.coffee', -> invoke 'deploy'

