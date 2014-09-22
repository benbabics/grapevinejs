'use strict';
var util = require('util');
var yeoman = require('yeoman-generator');
var path = require('path');


var SpecGenerator = yeoman.generators.NamedBase.extend({
  init: function (name, pathname) {
    this.pathname = pathname ? pathname : './';
  },

  files: function () {
    var id = this._.underscored( this.name );
    var class_name = this._.classify( id );
    var file_spec = this.pathname + '/spec/'+ class_name +'Spec.coffee';

    // template context
    var context = {
        id: id,
        name_controller: class_name + 'Spec'
    };

    console.log(id, class_name, file_spec);

    // render and insert template
    this.template( '_spec.coffee', file_spec, context );
  }
});

module.exports = SpecGenerator;