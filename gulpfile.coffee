gulp = require 'gulp'
$ = require('gulp-load-plugins')()
argv = require('yargs').argv

clazz = ->
  val = argv.clazz
  unless val
    throw "no clazz"
  val

gulp.task 'cp', ['clean'], ->
  gulp.src "src/#{clazz()}/*"
    .pipe gulp.dest 'build/'

gulp.task 'pandoc', ['cp'], ->
  gulp.src "build/*.md"
    .pipe $.shell(['pandoc --smart -o <%= name(file.path) %>.tex <%= file.path %>'],
      templateData:
        name: (s) ->
          parts = s.split('/')
          parts[parts.length - 1].replace(/\..*$/, '')
    )
    # .pipe $.shell(["echo '<%= file.base %>' "])

gulp.task 'pdf', ['pandoc'], ->
  gulp.src 'main.tex', {cwd: "build/"}
    .pipe $.shell(
      [
        'pdflatex --shell-escape <%= strip(file.path) %>',
        'pdflatex --shell-escape <%= strip(file.path) %>'
      ],
      verbose: true
      interactive: true
      cwd: '<%= file.cwd %>'
      templateData:
        strip: (s) ->
          console.log s
          s.replace(/\..*$/, '')
    )

gulp.task 'clean', ->
  gulp.src 'build/*'
    .pipe $.clean()

gulp.task 'default', ['pdf']
