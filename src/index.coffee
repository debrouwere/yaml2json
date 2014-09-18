_ = require 'underscore'
_.str = require 'underscore.string'
parsers =
    yaml: require 'js-yaml'
    textile: require 'textile-js'
    markdown: require 'markdown'
    asciidoc: require 'asciidoctor.js'


MULTIDOC_TOKEN = '---\n'
MULTIDOC_DELIMITER = /\n*?\-{3}\n+/
YAML_HASH_TOKEN = /^\n*?[a-z0-9_]+\s*?: /
YAML_LIST_TOKEN = /^\n*?\- /


# gets rid of the ridiculous iterator interface to yaml.safeLoadAll
parsers.yaml.safeIterate = parsers.yaml.safeLoadAll
parsers.yaml.safeLoadAll = (raw) ->
    isMultidoc = _.str.startsWith raw, MULTIDOC_TOKEN
    data = []
    parsers.yaml.safeIterate raw, data.push

    if isMultidoc
        data
    else
        data[0]

parsers.yaml.isMultidoc = isMultidoc = (raw) ->
    _.str.startsWith raw, MULTIDOC_TOKEN

parsers.yaml.isProbablyText = isProbablyText = (str) ->
    not (YAML_HASH_TOKEN.exec str) and not (YAML_LIST_TOKEN.exec str)

# a more flexible way to load mixed-format (data and text) documents 
# than just assuming frontmatter and a document, but at the same time
# more forgiving than yaml.safeLoadAll
parsers.yaml.safeLoadMixed = (raw) ->
    if isMultidoc raw
        data = []
        for doc in (raw.split MULTIDOC_DELIMITER)[1..]
            if isProbablyText doc
                data.push doc
            else
                try
                    data.push parsers.yaml.safeLoad doc
                catch err
                    if err instanceof parsers.yaml.YAMLException
                        data.push doc
                    else
                        throw err
        data
    else
        parsers.yaml.safeLoad raw


module.exports = (raw, options={}) ->
    if options.fussy
        docs = parsers.yaml.safeLoadMixed raw
    else
        docs = parsers.yaml.safeLoadAll raw

    if options.convertAll
        throw new Error "Not implemented yet."
    else if options.convert
        docs = docs.map (doc) ->
            if typeof doc is 'string'
                # TODO: make it so that `parsers` actually
                # contains the converting functions (or 
                # use a separate collection variable), not
                # the modules, otherwise this won't work
                html = parsers[options.format] doc
                if options.keepRaw
                    wrapper = {html}
                    wrapper[options.format] = doc
            else
                doc

    if isMultidoc raw
        docs
    else
        docs[0]
