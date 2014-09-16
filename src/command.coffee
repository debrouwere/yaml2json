program = require 'commander'
parser = require './'

program
    .option '-f, --fussy', 
        'Be fussy about which documents to interpret as YAML, lax about which to interpret as text.'
    .option '-c --convert [markdown|asciidoc|textile]', 
        'Convert text documents into HTML using the markup language of your choice.'
    .option '-C, --convert-all', 
        'Convert every string into HTML using the markup language of your choice.'
    .option '-k, --keep-raw', 
        'Keep raw markup and HTML for parsed strings.'
    .option '-h, --human', 
        'Return a more user-friendly data structure.'
    .option '-d, --document', 
        'Assume only the topmost document is YAML: the metadata of a document.'
    .parse process.argv

console.log program