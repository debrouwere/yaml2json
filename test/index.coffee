###
These tests are not comprehensive, but they do serve as a sanity check
by proving changes haven't accidentally broken *everything*.
###

fs = require 'fs'
{exec} = require 'child_process'
should = require 'should'
yaml2json = require '../src'

describe 'yaml2json: module', ->
    it 'can convert yaml into json', ->
        multidoc = fs.readFileSync 'examples/musicman.md', encoding: 'utf8'
        object = yaml2json multidoc
        object.should.be.an.instanceOf Array
        object.length.should.eql 5
        object[0].title.should.eql \
            'The Music Man'
        object[1].should.be.an.instanceOf Object

    it 'can be fussy about which documents to parse', ->
        multidoc = fs.readFileSync 'examples/musicman.md', encoding: 'utf8'
        object = yaml2json multidoc, fussy: yes
        object.should.be.an.instanceOf Array
        object.length.should.eql 5
        object[1].should.be.an.instanceOf String
    
    it 'can convert markdown documents'
    it 'can convert asciidoc documents'
    it 'can convert textile documents'
    it 'can convert strings inside of objects'

    it 'can transform objects that represent simple documents 
    into a more developer-friendly format'

describe 'yaml2json: command-line interface', ->
    it 'works on the command-line', (done) ->
        path = 'examples/musicman.md'
        command = "./bin/yaml2json #{path} \
            --fussy \
            --convert-all"
        exec command, (err, stdout, stderr) ->
            stdout.should.be.an.instanceOf String
            parsed = JSON.parse stdout
            parsed.length.should.eql 5
            parsed[0].title.should.eql \
                'The Music Man'
            parsed[4].alternatives[0].should.eql \
                'The Music Man <em>(2003 film)</em>'
            done err

    it 'can detect the markup format from the file extension'