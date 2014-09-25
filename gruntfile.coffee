# Grunt configuration
app_config =
  # The web app directory
  app    : './'
  # The source directory for uncompiled and static assets
  src    : 'static_src'
  # The release directory to compile to
  release: 'static'
  # 3rd party lib directories
  components:
    # All libraries
    all      : 'lib'
    # Bower libraries
    managed  : 'lib/bower_components'
    # Manually install and tracked libraries
    unmanaged: 'lib/other_components'
  # The requirejs buildfile
  build: require './buildfile'

# Grunt definitions
grunt_fn = (grunt) ->

  # Load all grunt tasks
  require('load-grunt-tasks') grunt,
    pattern: [
      'grunt-*'
      # Exclusions
      '!grunt-template-jasmine-requirejs'
    ]

  # Grunt configuration
  grunt_config =

    app_config: app_config

    clean:
      ###*
       * Cleans the .tmp directory
      ###
      tmp: '<%= app_config.src %>/.tmp'
      ###*
       * Cleans the static directory
      ###
      release: '<%= app_config.release %>'

    coffee:
      ###*
       * Compile Coffeescript for release. Compiles to
       * a .tmp/js directory
      ###
      release:
        files: [{
          expand: true
          cwd: '<%= app_config.src %>/coffee'
          src: '**/*.coffee'
          dest: '<%= app_config.src %>/.tmp/js'
          ext: '.js'
        }]

      ###*
       * Compile Coffeescript during development. Compiles
       * directly to /js.
      ###
      dev:
        files: [{
          expand: true
          cwd: '<%= app_config.src %>/coffee'
          src: '**/*.coffee'
          dest: '<%= app_config.release %>/js'
          ext: '.js'
        }]

      test:
        files: [{
          expand: true
          cwd: '<%= app_config.src %>/test/spec'
          src: '**/*.coffee'
          dest: '<%= app_config.release %>/test/spec'
          ext: '.js'
        }]

    concurrent:
      ###*
       * Concurrently watches directories for changes and runs the
      ###
      dev:
        tasks : [
          'watch'
        ]
        options :
          # Pipe output of all processes to the stdout
          logConcurrentOutput : true

    # The actual grunt server settings
    connect:
      options:
        port: 9000
        open: true
        livereload: 35729
        # Change this to '0.0.0.0' to access the server from outside
        hostname: 'localhost'

      livereload:
        options:
          middleware: (connect) ->
            [
              connect.static(app_config.release)
              connect().use("/#{app_config.release}", connect.static(app_config.release))
            ]

    sass:
      ###*
       * Compiles SASS for release. Compiles to a .tmp/css directory.
      ###
      release:
        files: [{
          expand: true
          cwd: '<%= app_config.src %>/scss/'
          src: '**/*.scss'
          dest: '<%= app_config.src %>/.tmp/css'
          ext: '.css'
        }]
      ###*
       * Compiles SASS for development. Compiles directly to static/css.
      ###
      dev:
        files: [{
          expand: true
          cwd: '<%= app_config.src %>/scss/'
          src: '**/*.scss'
          dest: '<%= app_config.release %>/css'
          ext: '.css'
        }]
      options:
        # Compress css
        style: '  compressed'
        # Load from local scss and external libraries
        loadPath: [
          '<%= app_config.src %>/scss'
          '<%= app_config.src %>/<%= app_config.components.managed %>'
          '<%= app_config.src %>/<%= app_config.components.unmanaged %>'
        ]

    copy:
      ###*
       * Copies all libs from the source directory to the static directory
      ###
      lib:
        files:[
          dot    : true
          expand : true
          cwd    : '<%= app_config.src %>'
          dest: '<%= app_config.release %>'
          src: '<%= app_config.components.all %>/**/*'
        ]
      ###*
       * Copies all fonts from the source directory to the static directory
      ###
      fonts:
        files:[
          cwd    : '<%= app_config.src %>/<%= app_config.components.managed %>/Font-Awesome'
          expand : true
          dest: '<%= app_config.release %>'
          src: 'fonts/**'
        ]
      ###*
       * Copies all images from the source directory to the static directory
      ###
      templates:
        files: [
          expand : true
          cwd    : 'templates'
          dest: '<%= app_config.release %>'
          src: '*.html'
        ]
      ###*
       * Copies all images from the source directory to the static directory
      ###
      images:
        files: [
          dot    : true
          expand : true
          cwd    : '<%= app_config.src %>'
          dest: '<%= app_config.release %>'
          src: 'images/**/*'
        ]
      ###*
       * Copies all CSS from the .tmp directory to the static directory
      ###
      tmp_css:
        files:[
          dot    : true
          expand : true
          cwd    : '<%= app_config.src %>'
          dest: '<%= app_config.release %>'
          src: '.tmp/**/*.css'
        ]
      ###*
       * Copies all JS from the .tmp directory to the static directory
      ###
      tmp_js:
        files:[
          dot    : true
          expand : true
          cwd    : '<%= app_config.src %>'
          dest: '<%= app_config.release %>'
          src: '.tmp/**/*.js'
        ]

    jasmine:
      ###*
       * Runs all Jasmine tests
      ###
      all:
        src: '<% app_config.release %>/js/**/*.js'
        options:
          keepRunner: true
          specs : '<%= app_config.release %>/test/spec/{,*/}*.js'
          template: require( 'grunt-template-jasmine-requirejs' )
          templateOptions:
            requireConfigFile: './static/js/main.js'
            requireConfig:
              baseUrl: 'static/js'

    requirejs:
      ###*
       * Runs the requirejs optimizer and compiles the necessary files
      ###
      compile:
        options: app_config.build

    watch:
      ###*
       * Livereload whenever an .html file change
      ###
      html:
        files: [
          'templates/*.html'
        ]
        tasks: ['copy:templates']
        options:
          livereload: true

      ###*
       * Compile and livereload when a SCSS file changes
      ###
      css:
        files: ['<%= app_config.src %>/scss/**/*.scss']
        tasks: ['sass:dev']
        options:
          livereload: true
          # Required to avoid 'build' being run twice
          spawn: false

      ###*
       * Compile and livereload when a Coffescript file changes
      ###
      js:
        files: ['<%= app_config.src %>/coffee/**/*.coffee']
        tasks: ['coffee:dev']
        options:
          livereload: true
          # Required to avoid 'build' being run twice
          spawn: false

      ###*
       * Copy to the static directory and livereload whenever an
       * image file changes
      ###
      images:
        files:['<%= app_config.src %>/images/**/*']
        tasks: ['copy:images']
        options:
          livereload: true

      livereload:
        options:
          livereload: '<%= connect.options.livereload %>'
        files: [
          # 'templates/{,*/}*.html'
        ]

      # TODO: We need to write some jasmine tests and execute them at the proper times
      # test:
      #   files: ['<%= app_config.src %>/**/*.coffee']
      #   tasks: ['build:test','jasmine']

  # register tasks

  ###*
   * Copies all needed files from the .tmp directory to the static directory
  ###
  grunt.registerTask 'copy:release', [
    'copy:lib'
    'copy:fonts'
    'copy:images'
    'copy:tmp_css'
    'copy:tmp_js'
  ]

  ###*
   * Copies all needed files from the src directory to the static directory (sans Coffeescript and SCSS)
   * @type {[type]}
  ###
  grunt.registerTask 'copy:dev', [
    'copy:lib'
    'copy:fonts'
    'copy:images'
    'copy:templates'
  ]

  ###*
   * Compiles all files needed for release (to the .tmp directory)
   * i.e. Coffeescript and SCSS
  ###
  grunt.registerTask 'compile:release', [
    'coffee:release'
    'sass:release'
  ]

  ###*
   * Compiles all files needed for development (straight to the static directory)
   * i.e. Coffeescript and SCSS
  ###
  grunt.registerTask 'compile:dev', [
    'coffee:dev'
    'sass:dev'
  ]

  ###*
   * Compiles JS test files
  ###
  grunt.registerTask 'compile:test', [
    'coffee:test'
  ]

  ###*
   * The full build process for release.
   *
   * Cleans, compiles, optimizes requirejs, and copies all files to the
   * static directory. Trashes the .tmp directory as cleanup.
  ###
  grunt.registerTask 'build:release', [
    'clean'
    'compile:release'
    'requirejs'
    'copy:release'
    'clean:tmp'
  ]

  ###*
   * The build process for development.
   *
   * Cleans, compiles, and copies all files straight to the release directory.
   * No requirejs optimization.
  ###
  grunt.registerTask 'build:dev', [
    'clean'
    'compile:dev'
    'copy:dev'
  ]

  # TODO: Implement and improve
  # grunt.registerTask 'build:test', [
  #   'compile:dev'
  #   'compile:test'
  #   'jasmine'
  # ]

  # TODO: Implement and improve
  # grunt.registerTask 'test', [
  #   'build:test'
  #   'watch:test'
  # ]

  ###*
   * The default 'grunt' task.
   *
   * Performs a development build.
   *
   * Long-running while watching all files and running the
  ###
  grunt.registerTask 'default', [
    'build:dev'
    'connect:livereload'
    'watch'
  ]

  # Initialize grunt
  grunt.initConfig grunt_config

# Export grunt
module.exports = grunt_fn