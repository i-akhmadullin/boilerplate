module.exports = (grunt) ->
  'use strict'

  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);

  @initConfig


    sprite:
      all:
        src:       ['blocks/**/*_sprite.png']     # Sprite files to read in
        destImg:   'publish/sprite.png'           # Location to output spritesheet
        destCSS:   'blocks/sprite_positions.styl' # Stylus with variables under sprite names
        # imgPath:   'sprite.png' # OPTIONAL: Manual override for imgPath specified in CSS
        algorithm: 'top-down'   # top-down, left-right, diagonal, alt-diagonal, binary-tree [best packing]
        engine:    'auto'       # OPTIONAL: Specify engine (auto, canvas, gm)
        cssFormat: 'stylus'     # OPTIONAL: Specify CSS format (inferred from destCSS' extension by default) (stylus, scss, sass, less, json)
        imgOpts:                # OPTIONAL: Specify img options
          format: 'png'         # Format of the image (inferred from destImg' extension by default) (jpg, png)
          # quality: 90         # Quality of image (gm only)


    connect:
      uses_defaults: {}


    copy:
      images:
        files: [{
          expand:  true
          flatten: true
          cwd:     'blocks',
          src:     ['**/*.{png,jpg,jpeg,gif}', '!**/*_sprite.{png,jpg,jpeg,gif}']
          dest:    'publish'
        }]
      assets:
        files: [{
          expand:  true
          flatten: true
          cwd:     'blocks',
          src:     '**/*.{ttf,eot,svg,woff}'
          dest:    'publish'
        }]


    clean:
      pubimages:
        src: [
          "publish/*.png",
          "publish/*.gif",
          "publish/*.jpg",
          "publish/*.jpeg",
          "!publish/sprite.png"
        ]


    imagemin:
      options:
        optimizationLevel: 5
      dist:
        files: [
          {
            expand: true
            cwd:    'publish/'
            src:    '**/*.{png,jpg,jpeg}'
            dest:   'publish/'
          },
          {
            expand: true
            cwd:    'tmp/'
            src:    '**/*.{png,jpg,jpeg}'
            dest:   'tmp/'
          },
          {
            expand: true
            cwd:    './'
            src:    '*.{png,jpg,jpeg,ico}'
            dest:   './'
          },
        ]


    bower:
      install:
        options:
          targetDir:      './lib'
          layout:         'byType'
          install:        true
          verbose:        false
          cleanTargetDir: false
          cleanBowerDir:  true


    concat:
      js:
        src: [
          'lib/consoleshiv.js',
          'lib/**/*.js',
          '!lib/jquery/*.js',
          '!lib/html5shiv/*.js',
          'blocks/**/*.js'
        ]
        dest: 'publish/script.js'


    uglify:
      dist:
        files:
          '<%= concat.js.dest %>': ['<%= concat.js.dest %>']


    jshint:
      files: [
        'blocks/**/*.js'
      ]
      options:
        curly:    true
        eqeqeq:   true
        eqnull:   true
        # quotmark: true
        undef:    true
        unused:   false

        browser:  true
        jquery:   true
        globals:
          console: true


    watch:
      options:
        livereload: false
        spawn:      false

      publish:
        options:
          livereload: true
        files: [
          'publish/script.js',
          'publish/style.css'
        ]

      js:
        files: [
          'lib/**/*.js',
          'blocks/**/*.js'
        ]
        tasks: ['concat:js']

      css:
        files: [
          'blocks/**/*.css',
          'blocks/**/*.styl',
        ]
        tasks: ['stylus:dev', 'stylus:dev_ie']

      jade:
        options:
          livereload: true
        files: [
          'jade/**/*.jade'
        ]
        tasks: ['jade:dev']

      images:
        files: [
          'blocks/**/*.png',
          'blocks/**/*.jpg',
          'blocks/**/*.jpeg',
          'blocks/**/*.gif'
        ]
        tasks: ['copy:images']


    jade:
      options:
        pretty:  true

      dev:
        options:
          data:
            ga:      'UA-XXXXX-X'
            metrika: 'XXXXXXX'
            isDevelopment: true
        files: [{
          expand: true       # Enable dynamic expansion.
          cwd:    'jade'     # Src matches are relative to this path.
          src:    '*.jade'   # Actual pattern(s) to match.
          dest:   ''         # Destination path prefix.
          ext:    '.html'    # Dest filepaths will have this extension.
        }]

      publish:
        options:
          data:
            ga:      '<%= jade.dev.options.data.ga %>'
            metrika: '<%= jade.dev.options.data.metrika %>'
            isDevelopment: false
        files: '<%= jade.dev.files %>'


    stylus:
      options:
        compress: false
        paths: ['blocks/']
        import: [
          'config',
          'i-mixins/i-mixins__clearfix.styl',
          'i-mixins/i-mixins__vendor.styl',
          'i-mixins/i-mixins__gradients.styl',
          'i-mixins/i-mixins__if-ie.styl',
          'sprite_positions.styl',
        ]

      dev:
        options:
          define:
            ie: false
        files:
          'publish/style.css': [
            'lib/normalize-css/normalize.css',
            'blocks/i-reset/i-reset.styl',
            'lib/**/*.css',
            'blocks/b-*/**/*.css',
            'blocks/b-*/**/*.styl',
            '!blocks/i-*/'
          ]

      dev_ie:
        options:
          define:
            ie: true
        files:
          'publish/style.ie.css': [
            'blocks/i-reset/i-reset.styl',
            'lib/**/*.css',
            'blocks/b-*/**/*.ie.css',
            'blocks/b-*/**/*.ie.styl',
            '!blocks/i-*/'
          ]

      publish:
        options:
          compress: true
        files: 
          'publish/style.css': 'publish/style.css'
        # base64: true

      publish_ie:
        options:
          compress: true
        files: 
          'publish/style.ie.css': 'publish/style.ie.css'
        # base64: true


    open:
      mainpage:
        path: 'http://localhost:8000/main.html';


  @registerTask( 'default',    [ 'concat:js', 'stylus:dev', 'stylus:dev_ie', 'jade:dev' ])
  @registerTask( 'livereload', [ 'default', 'connect', 'open', 'watch' ])

  @registerTask( 'publish',    [ 'jshint', 'concat:js', 'uglify', 'stylus', 'jade:publish' ])

  # copy images from /blocks to /publish and then compress them
  @registerTask( 'publish_img', [ 'clean', 'copy', 'imagemin' ])