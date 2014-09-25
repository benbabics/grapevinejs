define [
  'BaseController'
],
(BaseController) ->


  class FooController extends BaseController

    initialize: (settings) ->
      @sandbox.value author: 'Ben Babics'

      # sandbox event listeners
      @sandbox.on 'controller:welcome', @handleControllerWelcome, @


    ###*
     * Event Handlers
    ###
    handleControllerWelcome: (greeting) ->
      author_txt = "Created by: #{@sandbox.value().author}"
      console?.log "#{greeting}, FooController!", @bootstrap, "\n#{author_txt}"


    ###*
     * Create & Destroy Methods
    ###
    onCreate: ->
      #

    onDestroy: ->
      #



  # exports
  FooController
