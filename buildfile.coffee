module.exports =

  appDir : 'static_src/.tmp/'

  baseUrl: 'js/'

  mainConfigFile: 'static_src/.tmp/js/main.js'

  dir: 'static'

  paths:
    # Libs
    backbone      : '../../lib/bower_components/backbone/backbone'
    jquery        : '../../lib/bower_components/jquery/jquery'
    localstorage  : '../../lib/bower_components/backbone.localStorage/backbone.localStorage-min'
    text          : '../../lib/bower_components/requirejs-text/text'
    underscore    : '../../lib/bower_components/underscore/underscore'
    # Core
    BaseController : 'core/controllers/BaseController'
    BaseModel      : 'core/models/BaseModel'
    BaseModule     : 'core/modules/BaseModule'
    BaseRouter     : 'core/routers/BaseRouter'
    BaseService    : 'core/services/BaseService'
    BaseView       : 'core/views/BaseView'
    facade         : 'core/facade'
    # Aliases
    helpers : 'core/helpers/'

  modules: [
    {
      name   : 'main'
      include: [
        'backbone'
        'bootstrap'
        'BaseModule'
        'BaseService'
        'BaseController'
        'BaseRouter'
        'BaseModel'
        'BaseView'
      ]
    }
    # !! Generator Adds Module Here !!
  ]
