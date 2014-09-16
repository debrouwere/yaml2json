There's no dearth of YAML parsers and YAML to JSON converters. This command-line utility was built to handle YAML files that contain multiple documents, data and text mixed together. It's great for working with the frontmatter-plus-content format that static site generators almost universally depend on.

### Text detection

A regular YAML parser will try to parse almost everything it humanly can into objects and arrays. For example, a text document that starts with "That is to say: an example." will be interpreted as a `That is to say` key with `an example.` as its value.

One way to solve this is to use the `--document` flag to tell `yaml2json` that you're dealing with a document that starts with YAML front matter (a.k.a. your document's metadata), followed by one or more text documents (a.k.a. your body copy). Only the first document in a multidoc will be interpreted as YAML, all further documents will be strings.

Another way to solve this is to use the `--fussy` flag to ask the parser to be more fussy, and only interpret something as an object or a string, rather than plain text, if it really unambigously looks like it: 

* object: `author: George Brassens`
* string: `Here's an artist you might like: George Brassens`
* array: `- don't forget to bring milk`
* string: `-- anyway, that's the end of it`

### Markup languages

`yaml2json` can optionally run strings through a Markdown, Textile or AsciiDoc converter, replacing those strings with the rendered HTML.

To convert only string documents in a multidoc, use `--convert`. To convert _any_ string, even those in objects and arrays, instead use `--convert-all`. (Do you put your document's title and summary in YAML frontmatter, and would you like to be able to use bold and italics for said title and summary? Then `--convert-all` is for you.)

If you'd like to keep the raw markup in addition to the HTML output from the parser, use the `--keep-raw` flag. Your string will be replaced by an object with two keys: 

* `html`
* `markdown`, `asciidoc` or `textile` keys depending on your markup language

### Pretty output

A multidoc is an array of documents, and that's what `yaml2json` will print out:

```json
[
    {
        "title": "...", 
        "author": "..."
    }, 
    {
        "markdown": "...", 
        "html": "...", 
    }
]
```

However, for simple documents that consist of YAML frontmatter plus content, a prettier output format is supported, which merges metadata (such as title and author) and content: 

```json
{
    "raw": "...", 
    "markdown": "...", 
    "title": "...", 
    "author": "..."
}
```

Use the `--pretty` flag to change output to this cleaner format.

In most cases, you'll want to combine the `--pretty` flag with `--convert` (to parse any markup) and `--document` (so that your content isn't accidentally parsed as YAML.)

### Use from node.js

    var yaml2json = require('yaml-to-json');
    yaml2json.load
    yaml2json.loadFirst
    yaml2json.loadAll

### Some thoughts about mixed-format YAML files.

The frontmatter-plus-content format is an elegant way to structure blog posts and other simple documents. But it's not the only way. The great thing about mixed-format YAML files is that you can mix up however many text and metadata blocks as you'd like.

How about this for a wiki page:

```yaml
---
block: metadata
title: The Music Man
year: 1962
---
In July 1912, a traveling salesman, "Professor" Harold Hill (Robert Preston), arrives in the fictional location of River City, Iowa, intrigued by the challenge of swindling the famously stubborn natives of Iowa.
---
block: cast
actors:
    - Robert Preston
    - Shirley Jones
---
In 2005, The Music Man was selected for preservation in the United States National Film Registry by the Library of Congress as being "culturally, historically, or aesthetically significant".
---
block: disambiguation
alternatives:
    - The Music Man (2003 film)
    - Music Man (company), a guitar company
    - The Music Man is the English name for the Iranian film Santouri (film)
```

When toying around with formats like these, don't forget to use the `--fussy` flag so as not to accidentally parse text as metadata.
