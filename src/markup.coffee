_ = require 'underscore'
_.str = require 'underscore.string'
fs = path: require 'path'
parsers =
    textile: require 'textile-js'
    markdown: require 'markdown'
    asciidoc: require 'asciidoctor.js'

{Opal} = parsers.asciidoc()
asciidocOptions = Opal.hash2 ['doctype', 'attributes'], 
    doctype: 'inline'
    attributes: ['showtitle']

converters =
    textile: parsers.textile.parse
    markdown: parsers.markdown.markdown.toHTML
    asciidoc: (string) -> parsers.asciidoc().Asciidoctor().$convert string, asciidocOptions

bare = (string) ->
    if _.str.contains string, '\n'
        string
    else
        string.replace /^<p>(.*)<\/p>$/, '$1'

exports.detect = (filename) ->
    name = filename.replace /\.ya?ml/g, ''
    extension = fs.path.extname name
    switch extension
        when '.md', '.markdown'   then return 'markdown'
        when '.textile'           then return 'textile'
        when '.asciidoc', '.adoc' then return 'asciidoc'
        else return undefined

exports.string = convertString = (string, options) ->
    html = converters[options.format] string

    if options.keepRaw
        wrapper = {html}
        wrapper[options.format] = string   
        wrapper
    else
        html

exports.object = convertObject = (obj, options) ->
    if obj.constructor is String
        html = convertString obj, options
        if options.bare
            bare html
        else
            html
    else if options.recursive
        nestedOptions = _.extend {bare: yes}, options
        convertNestedObject = _.partial convertObject, _, nestedOptions
        switch obj.constructor
            when Array
                _.map obj, convertNestedObject
            when Object
                _.object _.map obj, (value, key) ->
                    [key, convertNestedObject value]
            else
                obj
    else
        obj
