'use strict';
var util = require('util');
var yeoman = require('yeoman-generator');


var ServiceGenerator = yeoman.generators.NamedBase.extend({
    scaffoldDirectories: function() {
        var dir_name = this._.underscored( this.name );
        var coffee_path = 'coffee/' + dir_name;
        var spec_path = 'test/spec';

        // scaffold root dirs
        this.mkdir( coffee_path );

        // scaffold mvc dirs
        var _i, _len, dirs = ['collections','models','mixins','helpers'];
        for (_i = 0, _len = dirs.length; _i < _len; _i++) {
            this.mkdir( coffee_path +'/'+ dirs[_i] );
        }

        // create files
        this._createServiceFile( coffee_path );
        this._createSpecFile( spec_path );
    },

    _createServiceFile: function (dir_path) {
        var id = this._.underscored( this.name );
        var class_name = this._.classify( id );

        // template context
        var context = {
            id: id,
            name_service: class_name + 'Service'
        };

        // file names
        var file_main = dir_path +'/main.coffee';

        // render and insert templates
        this.template( '_service.coffee', file_main, context );
    },

    _createSpecFile: function(dir_path) {
        var class_name = this._.underscored( this.name );
        var file_spec  = dir_path +'/'+ class_name +'.coffee';

        console.log( '_createSpecFile', file_spec );
    }
});

module.exports = ServiceGenerator;