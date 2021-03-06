fs      = require 'fs'
glob    = require 'glob'
path    = require 'path'
extend  = require 'extend'
log     = require 'ewg-logging'
helper  = require('express-helpers')()
Globals = require './globals'


# this class represents the render context for a haml file
class EWGHamlContext
  # Any properties of this object are available in the Haml templates.
  constructor: (@config)->
    @helperLoaded = false
    @context = extend(
      {},
      # express helper simulating action view helper(ruby)
      helper,
      {
        log: log
        globals: new Globals(@config.globals)
        ws: @config.ws
      }
    )

  # TODO watch for helper change and reload if
  # load a module into the persistent context
  loadHelperIntoContext: (folder) =>
    helperPaths = glob.sync(folder)
    for helperPath in helperPaths
      trimmedPath = helperPath.substring(process.cwd().length + 1)
      console.log "loading haml helper #{trimmedPath.green}"
      @extend require(helperPath)

  loadHelperFirstTime: =>
    return if @helperLoaded

    @helperLoaded = true

    @loadHelperIntoContext path.join(__dirname, 'helper', '**/*.coffee')
    if @config.compiler.custom_helper?
      for chelper in @config.compiler.custom_helper
        @loadHelperIntoContext path.join(process.cwd(), chelper)


  # extend the persitent context
  extend: (object) =>
    extend(true, @context, object)

  # take copy from the persitent context
  new: (locals = {})=>
    @loadHelperFirstTime()

    extend(true, {}, @context, locals || {})

module.exports = EWGHamlContext
