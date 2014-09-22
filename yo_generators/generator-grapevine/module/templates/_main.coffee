define [
  'module'
  'facade'
  'BaseModule'
  './controllers/<%= name_controller %>'
],
(module, facade, BaseModule, <%= name_controller %>) ->


  class <%= name_module %> extends BaseModule

    controller: <%= name_controller %>

    constants:
      GREETING: 'Why, hello there'


    initialize: ->
      #


    createController: (Controller) ->
      # create the controller
      @controller = new Controller
        # bootstrap with module data
        bootstrap: module.config()
        # references
        views : {}
        models: {}

      # welcome the newly initialized controller
      @trigger 'controller:welcome', @constant().GREETING



  # register module with the facade
  facade.register '<%= id %>', <%= name_module %>
