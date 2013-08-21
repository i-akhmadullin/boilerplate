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
      server:
        options:
          port: 8000,
          base: ''
          middleware: (connect, options) ->
            return [
              # Serve static files.
              connect.static(options.base)
              # Show only html files and folders.
              connect.directory(options.base, { hidden:false, icons:true, filter:(file) ->
                return /\.html/.test(file) || !/\./.test(file);
              })
            ]


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
          "publish/*.{png,gif,jpg,jpeg}",
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

      css:
        src: [
          'lib/normalize-css/normalize.css',
          'blocks/i-reset/i-reset.css',
          'lib/**/*.css',
          '!lib/**/*.ie.css',
          'blocks/b-*/**/*.css',
          '!blocks/b-*/**/*.ie.css',
          '!blocks/i-*/'
        ]
        dest: 'publish/style.css'

      css_ie:
        src: [
          'blocks/i-reset/i-reset.ie.css',
          'lib/**/*.ie.css',
          'blocks/b-*/**/*.ie.css',
          '!blocks/i-*/'
        ]
        dest: 'publish/style.ie.css'


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

      stylus:
        options:
          livereload: true
        files: [
          'blocks/**/*.styl',
          '!blocks/**/*.ie.styl'
        ]
        tasks: ['stylus:dev', 'concat:css']

      stylus_ie:
        options:
          livereload: true
        files: [
          'blocks/**/*.ie.styl',
        ]
        tasks: ['stylus:dev_ie', 'concat:css_ie']

      js:
        options:
          livereload: true
        files: [
          'lib/**/*.js',
          'blocks/**/*.js',
          'Gruntfile.coffee'  # auto reload gruntfile config
        ]
        tasks: ['concat:js']

      jade:
        options:
          livereload: true
        files: [
          'jade/**/*.jade'
        ]
        tasks: ['jade:dev']

      images:
        files: [
          'blocks/**/*.{png,jpg,jpeg,gif}'
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
        expand: true       # Enable dynamic expansion.
        cwd:    'jade/'    # Src matches are relative to this path.
        src:    '*.jade'   # Actual pattern(s) to match.
        dest:   ''         # Destination path prefix.
        ext:    '.html'    # Dest filepaths will have this extension.

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
          'sprite_positions.styl'
        ]

      dev:
        expand: true
        cwd:    'blocks/'
        src:    [
          'i-reset/i-reset.styl',
          'b-*/**/*.styl',
          '!b-*/**/*.ie.styl',
        ]
        dest:   'blocks'
        ext:    '.css'

      dev_ie:
        options:
          define:
            ie: true
        expand: true
        cwd:    'blocks/'
        src: [
          'i-reset/i-reset.styl',
          'b-*/**/*.ie.styl',
        ]
        dest:   'blocks'
        ext:    '.ie.css'

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


  @event.on 'watch', (action, filepath) ->
    filepath = filepath.replace(/\\/g, '/'); # windows
    if grunt.file.isMatch( grunt.config('watch.stylus.files'), filepath)
      filepath = filepath.replace( grunt.config('stylus.dev.cwd'), '' );
      grunt.config( 'stylus.dev.src', filepath );
    if grunt.file.isMatch( grunt.config('watch.stylus_ie.files'), filepath)
      filepath = filepath.replace( grunt.config('stylus.dev_ie.cwd'), '' );
      grunt.config( 'stylus.dev_ie.src', filepath );
    if grunt.file.isMatch( grunt.config('watch.jade.files'), filepath)
      filepath = filepath.replace( grunt.config('jade.dev.cwd'), '' );
      grunt.config( 'jade.dev.src', filepath );


  @registerTask( 'default',    [ 'concat:js', 'stylus:dev', 'stylus:dev_ie', 'concat:css', 'concat:css_ie', 'jade:dev' ])
  @registerTask( 'livereload', [ 'default', 'connect', 'open', 'watch' ])

  @registerTask( 'publish',    [ 'jshint', 'concat:js', 'uglify', 'stylus:dev', 'stylus:dev_ie', 'concat:css', 'concat:css_ie', 'stylus:publish', 'stylus:publish_ie', 'jade:publish' ])

  # copy images from /blocks to /publish and then compress them
  @registerTask( 'publish_img', [ 'clean', 'copy', 'imagemin' ])