+++
Tags = ["search","gulp","node"]
date = "2017-07-23T17:28:52+02:00"
title = "Making a static site searchable"
Description = ""
Categories = ["development"]

+++

My site is getting pretty big now!  50+ posts, plus my journal entries from years past, I have content stretching over 4 years.
So I started thinking about ways to add search functionality.  And anyone who knows me knows I like to make these kind of things
more complicated than they need to be, so with that in mind I had a fun challenge to solve.  How do I add search functionality to
a static site?

## What's a static site?  And why is it hard to search it?

[Modern static sites](/post/2017/04_modern_static_sites) are compiled from Markdown files to create HTML.  My website is built using
[Hugo](https://gohugo.io), a static site generator.  What that means is that I have a folder full of partial HTML files, another folder
full of plain text files in a format called Markdown, a folder full of images/javascript/css, and when I type the command `hugo` in my
terminal, it combines all of those to create HTML files in an output folder.  So if you want to 
[download the source code for my blog](https://github.com/gburgett/blog), you're not getting HTML.  You're getting all the things
that go into creating the HTML.

So why does that matter for adding search functionality?  Well a static site, however it's generated, is just HTML, Javascript, CSS, and media.
None of those things run on the server.  To add search, I need to create a search index of my site and then provide a method to run queries against it.
Traditional ways of doing this require PHP or other server-side programming language, or an external 3rd party service like Google.  I'd rather
not rely on a 3rd party service at run time, and if I add PHP then I can't use super-cheap or free hosting like [netlify](https://www.netlify.com/) or
[Github Pages](https://pages.github.com/).  If I want to keep it a static-site, I have to provide search by serving only static files: HTML, JavaScript,
CSS, and assets.

## The plan

With those limits, I started doing some research and came across this Javascript library: [https://github.com/fergiemcdowall/search-index/](https://github.com/fergiemcdowall/search-index/).  
It allows you to build a search index and execute queries in it, in 100% javascript.  It even provides a bundle for use in the web browser!
So with that my plan was born.  I'd use [gulp](http://gulpjs.com/) to read all my markdown files and build an index of my website.  Then I'd serve
that index in a zipped file and download it in the browser, load it into the library, and execute searches.  Here was my plan of operation:

1. When I compile my site, use Gulp to also compile a search index.
  * Open a searchable index using the above library inside the running NodeJS process
  * Process each markdown file into a searchable document and add it to the index
  * Export the underlying database as a gzip file to the `public` directory
2. Serve the gzip file from the root of my web server
  * The web server just serves all files in the `public` directory, so just gotta put it in there.
3. Within the user's browser, download and load the search index
  * The index is easy to get, just need to do an XMLHttpRequest
  * Since it's GZip encoded, we need to inflate it using [pako](https://github.com/nodeca/pako) which is a javascript port of zlib
  * Then we load the database into the search-index library
4. Now we hook up a search bar to the library and run searches!
  * Just a simple HTML form with one input, where we intercept the onSubmit event
  * We'll render the search results to a simple HTML table and style it with CSS

## The Gulp tasks

[_Follow along with the actual code here_](https://github.com/gburgett/hugo-search-index/blob/master/src/gulp/index.ts)

Gulp is a NodeJS program, and a gulpfile is executed just like any other nodejs script.  Which means we can import the search-index library
and do things with it inside a gulp task.  So, the first thing to do is within our gulp task, open a search index [following the documentation](https://github.com/fergiemcdowall/search-index/blob/master/docs/create.md):

```js
gulp.task('build-search-index', (done) => {
  // load up our search-index so we can populate and export it
  const searchIndex = require('search-index')
  searchIndex({}, (openDatabaseError, index) => {
    if (openDatabaseError) {
      done(openDatabaseError)
      return
    }

```

Now, using Gulp's streaming API, we'll load all the markdown files into the search index:
```js
  // import all the markdown files into our search index
  gulp.src('./content/**/*.md')
  .pipe(buildDocument())
  .pipe(index.defaultPipeline())
  .pipe(index.add())
  .on('finish', (pipeErr) => {
    if (pipeErr) {
      done(pipeErr)
      return
    }

```

`buildDocument()` is a transform stream that I wrote which reads the contents of the markdown file, processes the front-matter which can be YAML,
TOML, or JSON, and builds a javascript object that ends up looking something like this:
```json
{ 
  "id": "post/2017/04_march_project.md",
  "date": "2017-04-05T22:08:16+02:00",
  "title": "March Project",
  "categories": ["cru","Albania"],
  "tags": ["cru","Albania"],
  "author": "gordon",
  "body": "## We love momentum\n\nMarch 13-17 was a big week for us.  We..."
}
```
All those fields become searchable.  So we can do things like narrow our search by tags or categories.  The most important thing though is to get
the `id` and `body` attributes.

Once we get the `finish` event on the pipeline, we can start exporting the index by modifying [these instructions in the documentation](https://github.com/fergiemcdowall/search-index/blob/master/docs/replicate.md#save-index-to-file):

```js
  index.dbReadStream({ gzip: true })
    .pipe(JSONStream.stringify(false))    // Using the JSONStream library we turn the database objects into strings
    .pipe(zlib.createGzip())              // Then we gzip the resulting stream of strings
    .pipe(fs.createWriteStream('./public/search_index.gz'))   // and write it to the output file
    .on('close', () => {
      
      // do some other checks...

      done()    // tell Gulp that this task finished successfully
```

Once that finishes we have our search index file in the `public/` directory!  Step 1 down :)

## Loading it in the browser

Once the gzip file is served it's pretty easy to download it.  For my site with 50 articles the index is about 650kb, so about the size of just one
modern javascript framework which gets loaded into your browser :).  I'm going to use typescript along with webpack to create the javascript bundle
which runs the search, so from now on you'll be looking at typescript code.

```ts
function downloadIndex(url: string, cb: (err, index?: Uint8Array) => void) {
  const oReq = new XMLHttpRequest()

  oReq.onload = (oEvent) => {
    const arrayBuffer = oReq.response // Note: not oReq.responseText
    if (arrayBuffer) {
      const byteArray = new Uint8Array(arrayBuffer)
      cb(null, byteArray)
    }
  }

  oReq.onerror = (oError) => {
    cb(oError)
  }

  oReq.responseType = 'arraybuffer'
  oReq.open('GET', url, true)
  oReq.send()
}
```

So this gets us a Uint8Array with the gzipped contents.  One note - depending on how it gets served, if it gets served as `Content-Encoding: gzip` and `Content-Type: application/octet-stream` it will be inflated automatically by Mozilla Firefox (and I assume by other browsers).  So we have to be aware of that, but also ready to unzip it ourselves using Pako.

```ts
function inflate(contents: Uint8Array, cb: (err: Error, inflated?: string) => void) {
  try {
    const inflated = pako.inflate(contents, { to: 'string' })
    cb(null, inflated)
  } catch (err) {
    if (err !== 'incorrect header check') {
      cb(err)
      return
    }

    // the browser already inflated this for us.
    // This happens if the server supports gzip encoding,
    // and sets the 'Content-Encoding: "gzip"' header.
    largeuint8ArrToString(contents, (result) => {
      cb(null, result)
    })
  }
}

function largeuint8ArrToString(uint8arr, callback) {
  const bb = new Blob([uint8arr])
  const f = new FileReader()
  f.onload = (e) => {
    callback((e.target as any).result)
  }

  f.readAsText(bb)
}
```

Now we have the unzipped search index as a string in the browser.  It looks a bit like this:

```
...
{"key":"TF~body~beat","value":[[0.5024271844660194,"albania/2016_YoungProfessionals.md"]]}
{"key":"TF~body~beatle&#39;s","value":[[0.5161290322580645,"post/2016/03_shift_musical.md"]]}
{"key":"TF~body~beautiful","value":[[0.5510204081632653,"post/2016/08_summer_recap.md"],[0.5277777777777778,"post/2016/06_its_summer.md"],[0.5266990291262136,"albania/2016_YoungProfessionals.md"],[0.5178571428571429,"post/2016/02_sometimes_its_tough.md"],[0.5175438596491229,"post/2017/07_home.md"],[0.5131578947368421,"post/2016/04_six_months_and_counting.md"],[0.5108695652173914,"post/2016/01_exploring-and-networking.md"],[0.5045045045045045,"post/2016/05_my_happy_place.md"],[0.502770083102493,"albania/2017.md"],[0.5022222222222222,"albania/2016_IceAndSpice.md"],[0.5018656716417911,"albania/2015.md"]]}
{"key":"TF~body~beauty","value":[[0.5161290322580645,"post/2014/12_realness-of-god.md"],[0.5102040816326531,"post/2015/01_euro-trip.md"]]}
...
```

So each line is a javascript object.  Time to read it and load it into our open `search-index` instance:

```ts
const options = this.options
SearchIndex(options, (libErr, si) => {
  if (libErr) {
    cb(libErr)
    return
  }

    // create a readable stream around our inflated string to read and JSON parse one line at a time
  let i = 0
  let lines = 0
  const docStream = new Readable({
    objectMode: true,

    read() {
      let chunk: any
      do {
        if (i >= inflated.length) {
            // we're done, tell the connected streams that we've got no more to send them.
          this.push(null)
          return
        }

          // find the next newline character and pull out this substring
        let nextNewline = inflated.indexOf('\n', i)
        if (nextNewline <= i) {
          nextNewline = undefined
        }
        const substr = inflated.substring(i, nextNewline)
        chunk = JSON.parse(substr)

          // If we didn't find another newline, we're at the end.  Can't break yet, still gotta push.
        if  (nextNewline) {
          i = nextNewline + 1
        } else {
          i = inflated.length
        }
        lines++

          // push the chunk and go read the next one, until the downstream pipe returns false.
          // If it returns false, we take a break until they call "read()" again on this instance.
      } while (this.push(chunk))
    },
  })

    // hook up our readable stream to the opened search index
  docStream
    .pipe(si.dbWriteStream({ merge: false }))
      // an empty listener lets the pipe keep moving, otherwise it gets stuck
    .on('data', () => {})
    .on('finish', () => {
        // Finished successfully!  Tell the main script that the search index is open.
      cb(null, si)
    })
    .on('error', (error) => {
      cb(error)
    })
})

```

You can see all this in the actual file [here](https://github.com/gburgett/hugo-search-index/blob/master/src/lib/search/SearchIndexLoader.ts).

## Executing a search

To execute a search, we need to generate a query object and execute the `search` method on the search index, as described [in the documentation](https://github.com/fergiemcdowall/search-index/blob/master/docs/search.md).
I built a wrapper object around the search index to handle this, with a method `executeSearch`.  [Here is the source](https://github.com/gburgett/hugo-search-index/blob/master/src/lib/search/store.ts).

```ts
public runSearch(query: string, lang?: string | SearchCallback, cb?: SearchCallback): void {
  if (!cb && typeof lang === 'function') {
    cb = lang
    lang = undefined
  }
  const results: SearchResult[] = []

  // search index only handles lower case - no matches on uppercase
  query = query.toLocaleLowerCase()

  const queryObj = {
    AND: {
      '*': query.split(' '),
    },
  }
    // add in the language to limit search results only to that language, for multilingual sites.
  if (lang) {
    (queryObj.AND as any).lang = [ lang ]
  }

  this.index.search({ query: queryObj })
    .on('data', (doc) => {
      results.push(doc)
    })
    .on('end', () => {
      cb(undefined, results)
    })
    .on('error', (error) => {
      cb(error)
    })
}
```

## Hooking it up to the search bar

The last step is hooking it all up!  We need a simple form with a text input, and a table for the results:

```html
<div>
  <form id="searchForm">
    <div class='searchContainer'>
      <input type="search" placeholder="Search..."></input>
      <i id="searchSpinner" class="fa fa-spinner fa-spin" aria-hidden="true"></i>
    </div>
  </form>
</div>

<div>
  <table id="searchResults">
  </table>
</div>
```

Then in the page's javascript we run all that above code to load the search index, and hook up to
the search form's `onSubmit` event.

```ts
  // Initialize the search index in the page context
InitSearch(url, (err, store) => {
  if (err) {
    console.error('Error loading search index: ' + err)
    return
  }
    // Search index initialized, add it to the window.
  w.Search = store
})

const searchForm = document.getElementById('searchForm')
const output = document.getElementById('searchResults')
const spinner = document.getElementById('searchSpinner')
if (spinner) {
  spinner.style.visibility = 'hidden'   // hidden while not searching
}
if (searchForm && searchForm instanceof HTMLFormElement) {
  searchForm.onsubmit = (evt) => {
    evt.preventDefault()
    const input = form.querySelector('input') as HTMLInputElement
    const text = input.value
    if (!text || text === '') {
        // do nothing for empty string search
      return
    }

    if (spinner) {
        // turn on the spinner while we search
      spinner.style.visibility = 'visible'
    }

    if (w.Search) {
        // already loaded
      doSearch(text)
    } else {
        // wait for loading to complete then do the search
      me.addEventListener('searchIndexLoaded', () => {
        doSearch(text)
      })
    }
  }
}

function doSearch(text: string): void {
  w.Search.runSearch(text, lang, (error, results) => {
    if (error) {
      console.error(error)
      return
    }

    if (output && output instanceof HTMLTableElement) {
      writeSearchResults(output, results)
    }
    if (spinner) {
      // now we stop the spinner
      spinner.style.visibility = 'hidden'
    }
  })
}

```

One last piece is writing the results to the table.  We get the results back as a javascript document
and need to format it into table rows.  That's this `writeSearchResults` function:

```ts
/** Formats and writes search results to the given HTMLTableElement in the <tbody> */
function writeSearchResults(table: HTMLTableElement, results: SearchResult[]): void {
  let body: HTMLTableSectionElement
  if (table.tBodies && table.tBodies.length > 0) {
    body = table.tBodies[0]
  } else {
    body = table.createTBody()
  }

  function resultToRow(r: SearchResult, row: HTMLTableRowElement): void {
    const date = r.document.date ? new Date(r.document.date).toLocaleDateString() : undefined
    let docBody: string = r.document.body
    if (docBody) {
      docBody = docBody.substring(0, 150) + '...'
    }
    row.innerHTML =
`<td>
  <h3><a href=${r.document.relativeurl}>${r.document.title || r.document.name}</a></h3>
  <span class="date">${date}</span>
  <div class="body">
      ${docBody}
  </div>
</td>`
  }

  let i = 0
  for (; i < body.rows.length && i < results.length; i++) {
    // overwrite existing rows
    resultToRow(results[i], body.rows[i])
  }

  for (; i < results.length; i++) {
    // append new rows as necessary
    resultToRow(results[i], body.insertRow())
  }

    // delete old rows
  for (; i < body.rows.length; ) {
      // since this is a live list, as we delete items it shrinks.  Thus we don't increment i.
    body.deleteRow(i)
  }

  if (results.length === 0) {
    const row = body.insertRow()
    row.innerHTML = '<h3>No Results</h3>'
  }
}
```

That's how it works on my site!  Check it out for yourself [here](/search).

This is what it looks like to build my site now, with Gulp and Hugo:

![A gif showing the build process](/images/2017/2017_07_build.gif)

Of course I have all that automated over at [Travis CI](https://travis-ci.org/gburgett/blog).  Whenever I push to my blog's github
repo, it automatically builds the `public` folder using Gulp, and then the Docker container using Docker, and pushes that to
the [official docker repository](https://hub.docker.com/r/gordonburgett/blog/).  Then my server automatically pulls the latest
docker image for the blog and deploys it.

## Wrapping it all up in a library

In working all this out, I had to learn about various ways to test javascript programs in the browser.  I used [Karma](https://karma-runner.github.io/1.0/index.html) in order to set up a test environment in Mozilla Firefox, and discovered
that the way `search-index` stores its underlying library is different in the NodeJS version and the browser version!
[I opened a bug report to address that](https://github.com/fergiemcdowall/search-index/issues/394) but also was able to create
a workaround. I also discovered a dozen other minor issues that had to be worked around.

To make it easier to share all this work, I've published it as an open source project and a nodejs library:

https://github.com/gburgett/hugo-search-index  
https://www.npmjs.com/package/hugo-search-index  

Now you can make your own search index just by installing the library and loading the gulp tasks in your gulpfile!
Hope you enjoyed this as much as I did, it was a fun challenge this week!
