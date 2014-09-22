'use strict';
var util = require('util');
var yeoman = require('yeoman-generator');


var ModuleGenerator = yeoman.generators.NamedBase.extend({
    init: function () {
        console.log('You called the module subgenerator with the argument ' + this.name + '.');
    },

    scaffoldDirectories: function() {
        var dir_name = this._.underscored( this.name );
        var coffee_path = 'coffee/' + dir_name;
        var spec_path = 'test/spec';

        // scaffold root dirs
        this.mkdir( 'scss/' + dir_name );
        this.mkdir( 'images/' + dir_name );
        this.mkdir( coffee_path );
        this.mkdir( spec_path );

        // scaffold mvc dirs
        var _i, _len, dirs = ['controllers','collections','models','views','templates','mixins','helpers'];
        for (_i = 0, _len = dirs.length; _i < _len; _i++) {
            this.mkdir( coffee_path +'/'+ dirs[_i] );
        }

        // create files
        this._createModuleFiles( coffee_path );
        this._createSpecFile( spec_path );
    },

    _createModuleFiles: function(dir_path) {
        var id = this._.underscored( this.name );
        var class_name = this._.classify( id );

        // template context
        var context = {
            id: id,
            name_module: class_name + 'Module',
            name_controller: class_name + 'Controller'
        };

        // file names
        var file_main = dir_path +'/main.coffee';
        var file_controller = dir_path +'/controllers/'+ class_name +'Controller.coffee'

        // render and insert templates
        this.template( '_main.coffee', file_main, context );

        // insert controller
        this.invoke( 'grapevine:controller', { args: [this.name, dir_path] } );
    },

    _createSpecFile: function(dir_path) {
        var class_name = this._.underscored( this.name );
        var file_spec  = dir_path +'/'+ class_name +'.coffee';

        console.log( '_createSpecFile', file_spec );
    },

    appendModuleToBuildFile: function() {
        var id = this._.underscored( this.name );
        var module_template = this.read( '_module.coffee' );
        var build_file_path = '../buildfile.coffee';
        var build_contents  = this.readFileAsString( build_file_path );
        var placeholder = '# !! Generator Adds Module Here !!';

        // render the module
        var module = this.engine( module_template, {id: id} );

        // cleanup whitespace
        module = this._.strip( module );

        // insert the module
        build_contents = build_contents.replace( placeholder, module );

        // write the file
        this.write( build_file_path, build_contents );
    }
});


module.exports = ModuleGenerator;
