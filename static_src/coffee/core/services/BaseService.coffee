define [
  'facade'
],
(facade) ->


  class BaseService

    ###
      # Service Responsibilities
    ###
    # hold state & data
    # encapsulate communication with an external webservice
    # handle non-view logic (permissible at the risk of codesmell)
    #
    constructor: ->
      # setup module constants
      setupConstants.call( @, @constants ) if @constants?

      # invoke initialize
      @initialize()


    ###
      # Abstract Methods
    ###
    initialize: ->


    ###
      # Private Methods
    ###
    setupConstants = (constants) ->
      # remove constants so they can't be added to at run-time
      `delete this.constants`

      # take the constants and set them
      @constant constants



  # exports
  BaseService
