define [
  'underscore'
  'jquery'
  'core/mediator'
],
(_, $, mediator) ->


  facade = {}


  ###
    # Modules
  ###

  facade.register = (channel, module) ->
    # normalize the channel
    channel = facade.util.decamelize( channel )

    # install the facade to the module prototype for this channel
    facade.installTo module, channel

    # register the module to the channel
    mediator.register channel, module


  facade.require = (dependency=[], callback) ->
    mediator.require.call @, dependency, callback


  facade.constant = (channel, configuration) ->
    mediator.constant channel, configuration


  facade.value = (channel, configuration) ->
    mediator.value channel, configuration


  ###
    # Pub/Sub
  ###

  facade.subscribe = (channel, subscription, context) ->
    mediator.subscribe channel, subscription, context


  facade.publish = (channel, args...) ->
    mediator.publish.apply @, arguments


  facade.once = (channel, subscription, context) ->
    facade.subscribe channel, facade.util.once( subscription ), context


  ###
    # DOM
  ###

  # Attempt to encapsulate low-level dom manipulation methods here to mitigate
  # module's having an explicit dependency on any particular dom manipulation library (jQuery, etc)
  # Encapsulating it here and being diligent to this way of thinking lends itself to easily swapping out libraries down the road.
  #
  facade.dom =
    create: (html, attrs={}) ->
      $ html, attrs

    find: (selector, context=document) ->
      return $( selector ) if selector is window
      $( context ).find selector

    data: (selector, attr='') ->
      $( selector ).data attr

    listen: (el, events, selector, callback) ->
      $( el ).on events, selector, callback


  ###
    # Utilities
  ###

  # Attempt to encapsulate low-level utility methods here to mitigate
  # module's having an explicit dependency on any particular utility library (jQuery, underscore, etc)
  # Encapsulating it here and being diligent to this way of thinking lends itself to easily swapping out libraries down the road.
  #
  facade.util = _.extend {}, mediator.util,

    extend_fn = (arg) ->
      lib = if arg is true then $ else _
      lib['extend']['apply']( null, arguments )

    each      : _.each
    once      : _.once
    omit      : _.omit
    keys      : _.keys
    pick      : _.pick
    omit      : _.omit
    filter    : _.filter
    reduce    : _.reduce
    throttle  : _.throttle
    debounce  : _.debounce
    isString  : _.isString
    isArray   : _.isArray
    isObject  : _.isObject
    isFunction: _.isFunction
    deferred  : $.Deferred
    method    : $.proxy
    'when'    : $.when
    extend    : extend_fn


  # InstallTo Object/Prototype
  #
  # Ability for the facade bound to a specific channel to be mixed into a child instance.
  # This will start from the module and be passed to it's children MVC.
  #
  facade.installTo = (obj={}, id) ->
    # normalize the channel (id)
    id = facade.util.decamelize( id ) if id?

    # retain the channel as it gets installed on children
    # note that the `id` will default to @__channel
    id = @__channel if @__channel?

    # Facades for pub/sub on children
    once_fn = (channel, subscription, context=@) ->
      facade.once "#{id}:#{channel}", subscription, context
      @

    subscribe_fn = (channel, subscription, context=@) ->
      facade.subscribe "#{id}:#{channel}", subscription, context
      @

    publish_fn = (channel, args...) ->
      arguments[0] = "#{id}:#{channel}"
      facade.publish.apply null, arguments
      @

    # Data Store for children
    data_fn = (type, configuration) ->
      channel = if facade.util.isString( configuration ) then configuration else id
      facade[type]( "#{channel}", configuration )

    # should we extending the prototype?
    obj = obj.prototype if typeof obj is 'function'


    # uses `on` instead of `subscribe`
    # uses `trigger` instead of `publish`
    # using these on instanes allow only the event to be included, and not the channel
    # e.g. <AppModule instance>@on( 'add' ) instead of <AppModule instance>@subscribe( 'app:add' )
    sandbox =
      once    : once_fn
      on      : subscribe_fn
      trigger : publish_fn
      value   : (config) => data_fn.call @, 'value',    config
      constant: (config) => data_fn.call @, 'constant', config

    # augement the child with the sandbox, facade and __channel
    facade.util.extend obj, facade, sandbox, { __channel: id }



  # return facade
  facade
