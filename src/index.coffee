_ = require 'underscore'
_.str = require 'underscore.string'
parsers =
    json: JSON
    yaml: require 'js-yaml'
    textile: require 'textile-js'
    markdown: require 'markdown'


MULTIDOC_TOKEN = '---\n'
MULTIDOC_DELIMITER = /\n*?\-{3}\n+/
YAML_HASH_TOKEN = /^\n*?\w+: /
YAML_LIST_TOKEN = /^\n*?\- /


parsers.yaml.isProbablyText = isProbablyText = (str) ->
    not (YAML_HASH_TOKEN.exec str) and not (YAML_LIST_TOKEN.exec str)


# a more flexible way to load mixed-format (data and text) documents 
# than just assuming frontmatter and a document, but at the same time
# more forgiving than yaml.safeLoadAll
parsers.yaml.loadMixed = (raw) ->
    isMultidoc = _.str.startsWith raw, MULTIDOC_TOKEN
    
    if isMultidoc
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


# gets rid of the ridiculous iterator interface 
# to yaml.safeLoadAll
parsers.yaml.loadDocuments = (raw) ->
    isMultidoc = _.str.startsWith raw, MULTIDOC_TOKEN
    data = []
    yaml.safeLoadAll raw, data.push

    if isMultidoc
        data
    else
        data[0]


parsers.isMixed = (filename, raw) ->
    hasMixedExtension = \
        (/\.ya?ml\.\w+$/.exec filename) or (/\.\w+\.ya?ml$/.exec filename)
    hasMultidocDeclaration = _.str.startsWith raw, MULTIDOC_TOKEN

    hasMixedExtension or hasMultidocDeclaration