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
    .option '-p --pretty', 
        'Indent the JSON output.'
    .option '-o --output',
        'Set output directory.'
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
indentation = if program.pretty then 2 else undefined

for content in contents
    object = parser content, program
    serialization = JSON.stringify object, undefined, indentation

    if program.output
        throw new Error "Not implemented yet."
        fs.writeFileSync
    else
        console.log serialization
