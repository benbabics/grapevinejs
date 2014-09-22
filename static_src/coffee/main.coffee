###
  ██████╗ ██████╗  █████╗ ██████╗ ███████╗██╗   ██╗██╗███╗   ██╗███████╗
 ██╔════╝ ██╔══██╗██╔══██╗██╔══██╗██╔════╝██║   ██║██║████╗  ██║██╔════╝
 ██║  ███╗██████╔╝███████║██████╔╝█████╗  ██║   ██║██║██╔██╗ ██║█████╗
 ██║   ██║██╔══██╗██╔══██║██╔═══╝ ██╔══╝  ╚██╗ ██╔╝██║██║╚██╗██║██╔══╝
 ╚██████╔╝██║  ██║██║  ██║██║     ███████╗ ╚████╔╝ ██║██║ ╚████║███████╗
  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚══════╝  ╚═══╝  ╚═╝╚═╝  ╚═══╝╚══════╝
###

# The build will inline common dependencies into this file.

requirejs.config

  baseUrl: '/static/js'

  shim:
    backbone:
      deps: [
        'jquery'
        'underscore'
      ]
      exports: 'Backbone'

    bootstrap:
      deps: ['jquery']
      exports: 'jquery'

    stripe_api:
      exports: 'Stripe'

    underscore:
      exports: '_'

  paths:
    # APIs
    stripe_api: 'https://js.stripe.com/v2/?1'
    # Libs
    jquery       : '../lib/bower_components/jquery/jquery'
    underscore   : '../lib/bower_components/underscore/underscore'
    backbone     : '../lib/bower_components/backbone/backbone'
    bootstrap    : '../lib/bower_components/sass-bootstrap/dist/js/bootstrap'
    localstorage : '../lib/bower_components/backbone.localStorage/backbone.localStorage-min'
    # RequireJS Plugins
    hbs          : '../lib/bower_components/require-handlebars-plugin/hbs'
    text         : '../lib/bower_components/requirejs-plugins/lib/text'
    async        : '../lib/bower_components/requirejs-plugins/src/async'
    # Core
    facade          : 'core/facade'
    BaseView        : 'core/views/BaseView'
    BaseModel       : 'core/models/BaseModel'
    BaseModule      : 'core/modules/BaseModule'
    BaseService     : 'core/services/BaseService'
    BaseController  : 'core/controllers/BaseController'
    # Services
    ResourceService : 'resource/main'
    StripeService   : 'stripe/main'
    UserService     : 'user/main'
    # Aliases
    helpers : 'core/helpers/'



# System module
define [
  'app/main'
],
(App) ->

  new App().start()
