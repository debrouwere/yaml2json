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
    
    it 'can convert markdown documents', ->
        multidoc = fs.readFileSync 'examples/musicman.md', encoding: 'utf8'
        object = yaml2json multidoc, 
            format: 'markdown'
            convert: yes
            fussy: yes
        object[1].should.match /<strong>River City, Iowa<\/strong>/

    it 'can convert asciidoc documents', ->
        multidoc = fs.readFileSync 'examples/tegucigalpa.adoc', encoding: 'utf8'
        object = yaml2json multidoc, 
            format: 'asciidoc'
            convert: yes
            fussy: yes
        object[1].should.match /Central America<\/a>/

    it 'can convert textile documents', ->
        multidoc = fs.readFileSync 'examples/antananarivo.textile', encoding: 'utf8'
        object = yaml2json multidoc, 
            format: 'textile'
            convert: yes
            fussy: yes
        object[1].should.match /<em>Tananarive<\/em>/

    it 'can convert strings inside of objects', ->
        multidoc = fs.readFileSync 'examples/musicman.md', encoding: 'utf8'
        object = yaml2json multidoc, 
            format: 'markdown'
            convertAll: yes
        object[4].alternatives[0].should.eql \
            'The Music Man <em>(2003 film)</em>'

    it 'can transform objects that represent simple documents 
    into a more developer-friendly format', ->
        multidoc = fs.readFileSync 'examples/musicman.md', encoding: 'utf8'
        object = yaml2json multidoc, 
            format: 'markdown'
            human: yes
        object.should.have.properties \
            'block'
            'title'
            'year'
            'markdown'
            'html'
            'more'
        object.more.length.should.eql 3

    it 'distinguishes multidocs from single documents', ->
        doc = fs.readFileSync 'examples/data.yml', encoding: 'utf8'        
        object = yaml2json doc
        object.should.be.an.instanceof Object
        object.should.have.properties \
            'description'
            'categories'

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
            done err

    it 'can detect the markup format from the file extension', ->
        format = (require '../src/markup').detect 'directory/file.adoc'
        format.should.eql 'asciidoc'
