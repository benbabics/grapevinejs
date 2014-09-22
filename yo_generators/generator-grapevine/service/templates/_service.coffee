define [
  'facade'
  'BaseService'
],
(facade, BaseService) ->


  class <%= name_service %> extends BaseService

    constants: {}

    initialize: ->
      #


    ###
      # Event Handlers
    ###



  # Register service
  facade.register '<%= id %>', <%= name_service %>