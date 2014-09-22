'use strict';
var util = require('util');
var yeoman = require('yeoman-generator');


var ControllerGenerator = yeoman.generators.NamedBase.extend({
  init: function (name, pathname) {
    this.pathname = pathname ? pathname : '.';
  },

  createControllerFile: function () {
    var id = this._.underscored( this.name );
    var class_name = this._.classify( id );
    var file_controller = this.pathname + '/controllers/'+ class_name +'Controller.coffee';

    // template context
    var context = {
        id: id,
        name_controller: class_name + 'Controller'
    };

    // render and insert template
    this.template( '_controller.coffee', file_controller, context );
  }
});

module.exports = ControllerGenerator;
