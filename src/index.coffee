_ = require 'underscore'
_.str = require 'underscore.string'
yaml = require './yaml'
# markup perhaps isn't the right name for this, 
# consider that it's actually converting *from*
# markup *to* html
markup = require './markup'

module.exports = (raw, options={}) ->
    if options.human
        _.extend options, 
            fussy: yes
            convert: yes
            keepRaw: yes

    if options.convert and not options.format
        throw new Error \
        "Cannot convert markup unless a format is provided."

    if options.human and not yaml.isMultidoc raw
        throw new Error \
        "Can only humanize YAML files that contain both frontmatter and content."

    if options.fussy
        docs = yaml.safeLoadMixed raw
    else
        docs = yaml.safeLoadAll raw

    if options.convert or options.convertAll
        conversionOptions = 
            format: options.format
            recursive: options.convertAll
            keepRaw: options.keepRaw
        convert = _.partial markup.object, _, conversionOptions
        docs = _.map docs, convert

    if options.human
        docs = _.extend docs[0], docs[1], more: docs[2..]

    if yaml.isMultidoc raw
        docs
    else
        docs[0]

module.exports.yaml = yaml