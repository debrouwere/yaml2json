_ = require 'underscore'
fs = require 'fs'
fs.path = require 'path'
fs.findit = require 'findit'
program = require 'commander'
parser = require './'

program
    .option '-c --convert [markdown|asciidoc|textile]', 
        'Convert Markdown, AsciiDoc and Textile documents into HTML.'
    .option '-C, --convert-all [markdown|asciidoc|textile]', 
        'Convert every string into HTML using the markup language of your choice.'
    .option '-f --fussy', 
        'Be fussy about which documents to interpret as YAML, lax about which to interpret as text.'
    .option '-k --keep-raw', 
        'Keep raw markup and HTML for parsed strings.'
    .option '-h --human', 
        'Return a more user-friendly data structure.'
    .option '-I --indent [n]', 
        'Indent the JSON output.', parseInt, 2
    .option '-o --output',
        'Set output directory.'
    .option '-F --force', 
        'Parse and convert even if output is newer than input.'
    .parse process.argv

input = fs.path.resolve program.args[0]
isDirectory = (fs.statSync input).isDirectory()

if isDirectory
    throw new Error "Not implemented yet."
    fs.findit
else
    contents = [fs.readFileSync input, encoding: 'utf8']

format = program.convertAll or program.convert
format = if typeof format is 'string' then format else false

unless format
    name = input.replace /\.ya?ml/g, ''
    extension = format or fs.path.extname name
    switch extension
        when '.md', '.markdown'   then format = 'markdown'
        when '.textile'           then format = 'markdown'
        when '.asciidoc', '.adoc' then format = 'asciidoc'

program.format = format

isNewer = (input, output) ->
    try
        input = (fs.statSync input).mtime
        output = (fs.statSync output).mtime
        input.getTime() > output.getTime()
    catch
        yes

yaml2json = (content, options) ->
    object = parser content, options
    serialization = JSON.stringify object, undefined, options.indent

for content in contents
    content2json = _.partial yaml2json, content, program

    if program.output
        throw new Error "Not implemented yet."
        if program.force or isNewer input, output
            fs.writeFileSync output, content2json(), encoding: 'utf8'
    else
        console.log content2json()
