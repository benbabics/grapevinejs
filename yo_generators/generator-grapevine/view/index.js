'use strict';
var util = require('util');
var yeoman = require('yeoman-generator');
var path = require('path');


var ViewGenerator = yeoman.generators.NamedBase.extend({
  init: function () {
    var module_id = path.resolve('.').split(path.sep).pop();
    this.module_id = module_id;
  },

  createViewFile: function () {
    var name = this._.underscored( this.name );
    var class_name = this._.classify( name );
    var file_view = './views/'+ class_name +'View.coffee';

    // template context
    var context = {
        id: this.module_id,
        name_view: class_name + 'View'
    };

    // render and insert template
    this.template( '_view.coffee', file_view, context );
  }
});

module.exports = ViewGenerator;
