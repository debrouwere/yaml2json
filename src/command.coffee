_ = require 'underscore'
fs = require 'fs'
fs.path = require 'path'
fs.mkdirp = require 'mkdirp'
program = require 'commander'
loader = require './loader'
markup = require './markup'
parser = require './'

program
    .usage '<file ...> [options]'
    .option '-c --convert [markdown|asciidoc|textile]', 
        'Convert Markdown, AsciiDoc and Textile documents into HTML.'
    .option '-C, --convert-all [markdown|asciidoc|textile]', 
        'Convert every string into HTML using the markup language of your choice.'
    .option '-f --fussy', 
        'Be fussy about which documents to interpret as YAML, lax about which to interpret as text.'
    .option '-k --keep-raw', 
        'Keep raw markup and HTML for parsed strings.'
    .option '-p --prose', 
        'Return a more user-friendly data structure, suited to simple prose documents.'
    .option '-I --indent [n]', 
        'Indent the JSON output.', parseInt, 2
    .option '-o --output <directory>',
        'Set output directory.'
    .option '-F --force', 
        'Parse and convert even if output is newer than input.'
    .parse process.argv


format = program.convertAll or program.convert
specifiedFormat = if typeof format is 'string' then format else false

parse = (content, options) ->
    object = parser content, options
    serialization = JSON.stringify object, undefined, options.indent

yaml2json = (content, source, format, root) ->
    program.format = specifiedFormat or format
    content2json = _.partial parse, content, program

    if program.output
        inputDir = root
        outputDir = fs.path.resolve program.output
        extension = fs.path.extname source
        destination = source
            .replace inputDir, outputDir
            .replace extension, '.json'
        if program.force or loader.isNewer source, destination
            fs.mkdirp.sync (fs.path.dirname destination)
            fs.writeFileSync destination, content2json(), encoding: 'utf8'
    else
        console.log content2json()

loader.load program.args, (err, files, root) ->
    for {content, path, format} in files
        yaml2json content, path, format, root
