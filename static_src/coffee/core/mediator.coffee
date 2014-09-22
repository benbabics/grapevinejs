define [
  'jquery'
  'underscore'
  'BaseService'
],
($, _, BaseService) ->


  mediator = {}
  modules  = {}


  ###
    # Utilities
  ###

  mediator.util =
    camelize: (str='') ->
      str.replace /(?:^|[\-_])(\w)/g, (delimeter, c) ->
        c.toUpperCase() or ''

    decamelize: (str='', delimeter='_') ->
      str = str.charAt(0).toLowerCase() + str.slice(1)
      str.replace( /([A-Z])/g, "#{delimeter}$1" ).toLowerCase()

    constantize: (str, delimeter) ->
      str = mediator.util.decamelize str.toLowerCase(), delimeter
      str.toUpperCase()

  ###
    # Modules
  ###

  # Register a module with the system
  #
  # @param  { string   } channel name, e.g. 'app:add'
  # @param  { function } module class
  # @return { function } when subclass of BaseModule
  # @return { object   } when subclass of BaseService
  #
  mediator.register = (channel, module) ->
    # init module if it's a sublcass of a service module
    module = new module() if module.__super__?.constructor is BaseService

    # create and assign the channel & module if they aren't already
    synthesizeModule channel, module


  # Require a module to be dynamically loaded at runtime
  #
  # @param  { string | array } one or many modules, e.g. ['referrals','picker']
  # @return { instance }
  #
  mediator.require = (deps=[], callback=->) ->
    # place single dependencies into an array, if it isn't already
    deps = [ deps ] if _.isString deps

    # loop through dependencies
    for channel in deps

      # synthesize the channel
      module = synthesizeModule channel

      # has our module already been assigned to the channel?
      if module?
        # publish an event that the module has loaded
        # pass the module as an argument for listeners to instantiate
        mediator.publish "#{channel}:loaded", module
        callback module

      # do we at-least have a channel?
      else if channel?

        # publish an event to our instance that is requiring this module
        # that the module is being required, and pass the modules name
        # this allows instances to be explicitly told to require a module
        # and require it at runtime without needing to know exactly which
        # module it is requiring. A bit of an edgecase, but this is how AppModule does it.
        @trigger( 'require', channel ) if @trigger?

        # publish an event to subscribers that the channel is loading
        mediator.publish "#{channel}:loading"

        # go and fetch the module
        request channel, callback

    @


  mediator.constant = (channel, configuration) ->
    synthesizeConstant channel, configuration


  mediator.value = (channel, configuration) ->
    synthesizeValue channel, configuration


  ###
    # Pub/Sub
  ###

  # Subscribe to a channel event
  #
  # @param  { string   } channel/event name, e.g. `app:add`
  # @param  { function } callback
  # @param  { object   } context, e.g. instance of AppModule
  # @return { void }
  #
  mediator.subscribe = (channels, subscription, context=@) ->
    # split channels into an array, space delimited
    for channel in channels.split ' '
      params   = getParams channel
      callback = -> subscription.apply context, arguments
      synthesizeEvent( params.channel, params.event ).push callback


  # Publish a channel event
  #
  # @param  { string } channel/event name, e.g. `app:add`
  # @params { anything you want }
  # @return { void }
  #
  mediator.publish = (channel, args...) ->
    params = getParams channel

    # notify event subscribers
    channels = synthesizeEvent( params.channel, params.event )
    subscription args... for subscription in channels

    # notify all subscribers
    channels = synthesizeEvent( params.channel, 'all' )
    arguments[0] = params.event
    subscription.apply null, arguments for subscription in channels


  ###
    # Private Methods
  ###

  # Convenience method for mediator.util.decamelize
  # @param  { string }, e.g. 'FooBar'
  # @return { string } normalized string, e.g. 'foo_bar'
  #
  normalize = (str) ->
    # Default the response to the parameter
    response = str

    if typeof(str) is 'string'
      # Decamelize if it's a string
      response = mediator.util.decamelize str

    response


  # Receive an `action` and split it into `channel` and `event`
  # This is primarliy used in @subscribe and @publish
  # @param  { string } action, e.g. 'app:add'
  # @return { object }, e.g. { channel: 'app', event: 'add' }
  #
  getParams = (action) ->
    # split the action into segments
    params = action.split ':'

    # return the action as params, default action to 'all'
    'channel': normalize( params.shift() )
    'event'  : normalize( params.join ':' ) or 'all'


  # Request modules on demand
  # @param  { string } channel 'app'
  # @return { void }
  #
  request = (channel, callback) ->
    # normalize the channel
    channel = normalize channel

    # Load our module. This will always be `main.coffee`
    require [ "#{channel}/main" ], (module) ->
      # assign the module class to the channel
      mediator.register channel, module
      # re-run back through require, to keep require logic DRY
      mediator.require channel, callback


  ###
    # The following methods are synthesize the `modules` object
  ###

  # Channel Synthesizer
  # @param  { string } channel, e.g. 'app'
  # @return { object }
  #
  synthesizeChannel = (channel) ->
    # normalize channel
    channel = normalize channel
    # synthesize the channel
    modules[ channel ] ?= {}


  # DataStore Synthesizer
  # @param  { string } channel, e.g. 'app'
  # @return { object }
  #
  synthesizeDs = (channel) ->
    channel = synthesizeChannel channel
    # synthesize a configuration-object for this channel
    channel.data ?= { store: { values: {}, constants: null } }


  # Value Synthesizer
  # @param  { string } channel, e.g. 'Users'
  # @param  { object } object, e.g. { title: 'Add a User' }
  # @return { object } values
  #
  synthesizeValue = (channel, config) ->
    # synthesize a configuration-object for this channel
    data = synthesizeDs channel

    # add config as a setter, and return the object
    if config?
      # set constants object
      values = data.store.values

      # loop through config
      values[ key ] = val for key, val of config

      # return configuration
      values

    # only chanel is supplied, return the config as a getter
    else
      data.store.values


  # Constant Synthesizer
  # @param  { string } channel, e.g. 'app'
  # @param  { object } object, e.g. { api_key: 'abc123' }
  # @return { object } constant(s)
  #
  synthesizeConstant = (channel, config) ->
    # synthesize a configuration-object for this channel
    data = synthesizeDs channel

    # add config as a setter, and return the object
    if config? and data.store.constants is null
      # set constants object
      data.store.constants = {}

      # loop through config
      for key, val of config
        key = mediator.util.constantize( key )
        data.store.constants[ key ] = val

      # return configuration
      data.store.constants

    # only chanel is supplied, return the config as a getter
    else
      data.store.constants or {}


  # Module Synthesizer
  # @param  { string   } channel, e.g. 'app'
  # @param  { function } module class
  # @return { function | null } module class or null
  #
  synthesizeModule = (channel, module) ->
    channel = synthesizeChannel channel
    # synthesize a module class to this channel
    channel['module'] ?= if module? then module else null


  # Event Synthesizer
  # @param  { string } channel, e.g. 'app'
  # @param  { string } event, e.g. 'add'
  # @return { array  } events array
  #
  synthesizeEvent = (channel, evt) ->
    channel = synthesizeChannel channel
    # synthesize `events` and the `event`
    events = channel[ 'events' ] ?= {}
    events[ evt ] ?= []



  # return mediator
  mediator
