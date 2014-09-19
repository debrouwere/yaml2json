_ = require 'underscore'
fs = require 'fs'
fs.path = require 'path'
fs.findit = require 'findit'
async = require 'async'

exports.extensions = extensions = [
    '.yml'
    '.yaml'
    '.md'
    '.markdown'
    '.textile'
    '.adoc'
    '.asciidoc'
    ]

exports.detectFormat = detectFormat = (path) ->
    name = path.replace /\.ya?ml/g, ''
    extension = fs.path.extname name
    switch extension
        when '.md', '.markdown'   then return 'markdown'
        when '.textile'           then return 'textile'
        when '.asciidoc', '.adoc' then return 'asciidoc'
        else return undefined

exports.isNewer = (input, output) ->
    try
        input = (fs.statSync input).mtime
        output = (fs.statSync output).mtime
        input.getTime() > output.getTime()
    catch
        yes

exports.load = (filenames, callback) ->
    isDirectory = (fs.statSync filenames[0]).isDirectory()

    if isDirectory
        directory = filenames[0]
        root = fs.path.resolve directory
        getPaths = (done) ->
            paths = []
            finder = fs.findit directory
            finder.on 'file', (file, stat) ->
                extension = fs.path.extname file
                if _.contains extensions, extension
                    paths.push fs.path.resolve file
            finder.on 'end', ->
                done null, paths
    else
        root = process.cwd()
        getPaths = (done) ->
            paths = (fs.path.resolve filename for filename in filenames)
            process.nextTick ->
                done null, paths

    getContent = (path, done) ->
        format = detectFormat path
        fs.readFile path, {encoding: 'utf8'}, (err, content) ->
            done err, {path, content, format}

    getContents = (paths, done) ->
        async.map paths, getContent, done

    async.waterfall [getPaths, getContents], (err, files) ->
        callback err, files, root