httpProxy = require 'http-proxy'
_ = require 'lodash'
fs = require 'fs'
path = require 'path'

module.exports = (grunt) ->

  pkg = grunt.file.readJSON './package.json'

  grunt.initConfig
    pkg: pkg

    clean:
      build: ['temp']

    coffee:
      default:
        expand: true
        flatten: false
        cwd: 'app'
        src: ['**/*.coffee']
        dest: 'temp/'
        ext: '.js'

    jade:
      default:
        expand: true
        flatten: false
        cwd: 'app'
        src: ['**/*.jade']
        dest: 'temp/'
        ext: '.html'

    stylus:
      default:
        expand: true
        flatten: false
        cwd: 'app'
        src: ['styles/*.styl']
        dest: 'temp/'
        ext: '.css'

    copy:
      build:
        files: [
          expand: true
          src: ['**/*.!(coffee|styl|jade)']
          dest: 'temp/'
          cwd: 'app'
        ]

    html2js:
      options:
        base: 'temp'
        module: 'app.templates'
        rename: (name) -> '/' + name
      main:
        src: ['temp/scripts/**/*.html']
        dest: 'temp/scripts/modules/templates.js'

    concat:
      app:
        dest: 'temp/app.js'
        src: [
          'temp/scripts/modules/**/index.js'
          'temp/scripts/modules/**/*.js'
          'temp/scripts/app.js'
          'temp/scripts/**/*.js'
          '!temp/scripts/tests/**/*.js'
          '!temp/scripts/bootstrap.js'
          'temp/scripts/bootstrap.js'
        ]
      tests:
        dest: 'temp/tests.js'
        src: [
          'temp/scripts/tests/**/*.js'
        ]

    connect:
      server:
        options:
          port: 3838
          base: 'temp'
          middleware: (connect, options) ->
            middlewares = []
            if Array.isArray(options.base)
              options.base = [options.base]

            extensionless = (base) ->
              return (req, res, next) ->
                fs.exists path.join(base, "#{req.url}.html"), (exists) ->
                  if exists
                    req.url = req.url + '.html'
                  next()

            middlewares.push extensionless('temp')
            
            directory = options.directory || options.base[options.base.length - 1]
            middlewares.push connect.static(options.base)
            middlewares.push connect.directory(directory)

            middlewares

    watch:
      default:
        files: [
          'app/**/*'
        ]
        tasks: ['build']

  for name of pkg.devDependencies when name.substring(0, 6) is 'grunt-'
    grunt.loadNpmTasks name

  grunt.registerTask 'default', [
    'build'
    'concat:tests'
    'connect'
    'watch'
  ]

  grunt.registerTask 'build', [
    'clean'
    'coffee:default'
    'jade:default'
    'stylus:default'
    'copy:build'
    'html2js'
    'concat:app'
  ]
