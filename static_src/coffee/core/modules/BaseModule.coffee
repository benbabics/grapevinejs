define [
  'facade'
  'BaseController'
],
(facade, BaseController) ->


  class BaseModule

    # this will old the controller factory
    __controller: null

    # ability to assign a controller class or a hash of controllers
    # this will be passed as a factory as the only argument to @createController
    # which can be used to determine which controller is needed from module logic
    controller: BaseController


    constructor: (settings={}) ->
      # setup module with stuff :)
      setupModule.call @

      # setup module constants
      setupConstants.call( @, @constants ) if @constants?

      # setup the controller factory
      setupControllerFactory.call @, @controller

      # setup listeners for when our module is requested to be added and removed
      @on 'add',    @handleAddingModule,   @
      @on 'remove', @handleRemovingModule, @

      # invoke initialize
      @initialize settings


    ### Convenience Methods ###
    start: (settings) ->
      @trigger 'add', settings


    stop: (settings) ->
      @trigger 'remove', settings


    ### Abstract Methods ###
    initialize: ->
      #

    createController: (Controller) ->
      # create the controller
      @controller = new Controller()


    destroyController: ->
      #


    ### Event Handlers ###
    handleAddingModule: (settings) ->
      # call our private methods setting the proper context of this instance
      # this method can be overriden as a hook for the "add" event
      # but "super" must be called in order to access the private method
      createController.call @, settings


    handleRemovingModule: (settings) ->
      # call our private methods setting the proper context of this instance
      # this method can be overriden as a hook for the "remove" event
      # but "super" must be called in order to access the private method
      destroyController.call @, settings


    ###
      # Static Properties
    ###
    @is_module: true


    ###
      # Private Methods
    ###
    setupModule = ->
      # allow modules to be auto-injected into the DOM once `loaded` and `create` events
      #  are triggered check for corresponding `outlet` to inject into
      @on 'create', ($module) =>
        $placeholder = @dom.find "[data-outlet='#{@__channel}:module']"
        $placeholder.html $module


    createController = (settings={}) ->
      # remove previous controller, if it exists
      destroyController settings

      # create the controller by calling abstract method
      # and pass in controller definition that now has facade mixed-in
      # __controller is a factory that accepts an id to return the appropriate controller
      @createController @__controller, settings

      # broadcast to other clients the state of the module
      # @controller.onCreate() is important because it is the mechanism to broadcast
      # the intial HTML fragment that subscribers are listening for. From there that
      # HTML fragment is the representation of your view(s) that gets re-rendered or filled-in.
      publishControllerState.call @, 'onCreate', 'create'


    destroyController = (settings={}) ->
      # do not proceed if the controller doesn't exist
      return unless @controller?

      # prepare for destruction of the controller
      @destroyController settings

      # broadcast to other clients the state of the module
      publishControllerState.call @, 'onDestroy', 'destroy'

      # remove the controller
      @controller = undefined


    setupConstants = (constants) ->
      # remove constants so they can't be added to at run-time
      `delete this.constants`

      # take the constants and set them
      @constant constants


    setupControllerFactory = (definition) ->
      # setup a factory of controllers that will be passed into @createController
      # that applicaiton logic can determine which controller to use
      factory = null

      # controller is setup, we'll clear it
      # this will be reassiged in @createController
      @controller = undefined

      # isntallTo an individual controller's prototype
      installToController = (Controller) =>
        @installTo ( Controller.prototype.sandbox ?= {} )

      # do we have a single controller?
      # when the factory is assigned this controller
      # mixin the sandbox into the prototype of the controller class
      if typeof definition is 'function'
        installToController definition
        # simply pass back the class of the controller
        factory = definition

      # apparently we have a hash of controllers. loop through the hash and
      # mixin the sandbox into the prototype of the respective controller class
      else
        installToController controller for id, controller of definition
        # if the factory gets called without an id, then default to BaseController
        factory = (id) -> if id? then definition[ id ] else BaseController

      # assign factory to our private property
      @__controller = factory


    publishControllerState = (method_name, state) ->
      # what is the response from this method? is it a string, or a promisary-object?
      response = @controller[ method_name ]?()

      # we need to account for promisary-objects
      # if it's not then wrap in a deferred and immediately resolve
      response = @util.deferred().resolve( response ) unless response?.done?

      # now broadcast the state with the data received
      response.done (data) => @trigger state, data



  # exports
  BaseModule
