define [
  'facade'
],
(facade) ->


  class BaseController

    constructor: (settings={}) ->
      # cache resources
      @collections = {}
      @models      = {}
      @views       = {}

      # install sandbox to settings resources
      installSandboxToResources.call @, settings

      # cache settings & bootstrap
      @settings  = settings
      @bootstrap = settings.bootstrap or {}

      # initially call initialize
      @initialize settings


    ### Abstract Methods ###
    initialize: -> #
    onCreate  : -> #
    onDestroy : -> #


    ###
      # Private Methods
    ###
    installSandboxToResources = (resources) ->
      # install sandbox on views
      for name, view of resources.views
        @views[ name ] = view
        installSandbox.call @, view

      # install sandbox on models
      for name, model of resources.models
        @models[ name ] = model
        installSandbox.call @, model

      # install sandbox on collections
      for name, collection of resources.collections
        @collections[ name ] = collection
        installSandbox.call @, collection


    installSandbox = (resource) ->
      # assign resource the prototype of a function
      resource = resource.prototype if typeof resource is 'function'

      # install sandbox to resource.sandbox
      @sandbox.installTo (resource.sandbox ?= {})



  BaseController
