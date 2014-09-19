_ = require 'underscore'
_.str = require 'underscore.string'
yaml = require './yaml'
# markup perhaps isn't the right name for this, 
# consider that it's actually converting *from*
# markup *to* html
markup = require './markup'

module.exports = (raw, options={}) ->
    if options.fussy
        docs = yaml.safeLoadMixed raw
    else
        docs = yaml.safeLoadAll raw

    if options.convert or options.convertAll
        conversionOptions = 
            format: options.format
            recursive: options.convertAll
        convert = _.partial markup.object, _, conversionOptions
        docs = _.map docs, convert

    if yaml.isMultidoc raw
        docs
    else
        docs[0]