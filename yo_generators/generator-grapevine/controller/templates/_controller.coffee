define [
  'BaseController'
],
(BaseController) ->


  class <%= name_controller %> extends BaseController


    initialize: (settings) ->
      # sandbox event listeners
      @sandbox.on 'controller:welcome', @handleControllerWelcome, @


    ###*
     * Event Handlers
    ###
    handleControllerWelcome: (greeting) ->
      console?.log "#{greeting}, <%= name_controller %>!", @bootstrap


    ###*
     * Create & Destroy Methods
    ###
    onCreate: ->
      #

    onDestroy: ->
      #



  # exports
  <%= name_controller %>
