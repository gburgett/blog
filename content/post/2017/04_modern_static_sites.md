+++
date = "2017-04-20T13:49:22+02:00"
title = "Modern Static Sites"
menu = "main"
Categories = ["development"]
Tags = ["development", "hugo", "javascript"]
Description = ""
aliases = [
  "/post/modern_static_sites/",
]

+++


Today in 2017, there are a thousand and one different ways to build a website.  As always there's good old fashioned [Wordpress](https://wordpress.com), and of course there's drag-n-drop website builders like [Wix](http://www.wix.com).  One thing these have in common is that they need a traditional hosting environment, and for that you gotta pay.

If you can manage it, the cheapest way to host a website nowadays is to create a static HTML site.  But don't hand-craft HTML, that's hard and boring.  Use a static site generator, for fun and profit!

[Skip over the part about setting up Hugo](#now-the-fun-part-spicing-up-the-javascript)

## Building a website the fun way

There's a whole ton of static site builders out there nowadays, written in all sorts of different languages.  This blog is written with [Hugo](https://gohugo.io).  Hugo is super easy to install on windows, mac and linux as well as being easy to get started with.  If you want a bit more control you can use [Jekyll](https://jekyllrb.com) instead and even write custom plugins.  The point is to separate out your content from your presentation, so that you can more easily "just write", and let the static site generator make your website.

#### Separate my what from my wha?

Every website is made up of 3 parts: Content, Presentation, and Data.  In a blog, your Content is your articles, events, images, etc.  It's stuff that you upload to present to your readers.  Data is things like comments, event regestrations, messages, user-uploaded images.  When your readers submit things to you and you have to store them somewhere.  Presentation is how you put all those things together to display them.  This includes themes, site layout, menus.

Every website builder needs to deal with those 3 parts and combine them together to display the website.  It also needs to allow the content creators (you & your friends/employees) to change the content, and to allow the web designers (you again for your personal blog, or the maintainer of the theme you chose) to edit the HTML and CSS styles.  Wordpress solves this problem on the server.  Content and Data are pulled from the SQL database and combined with the theme files in order to generate the webpage on request.  There's an admin section at `/wp-admin` which allows anyone with the correct password to change the Content, Data, and Presentation.  All of this happens on the web server

A static site generator does this in a completely different way.  First, it does away with the Data part entirely.  You can still have a site with Data, but you have to combine the statically-generated site with another service.  Then, the Content and Presentation are combined *on your laptop*.  You run the static site generator once, and it produces the resulting HTML, Javascript, and CSS in a folder for you to upload to your web server.  No more PHP, no more MySql, you only need Apache.

A static site is more secure, because the web server doesn't need to receive any Data from the user.  It doesn't have a `/wp-admin` section where a hacker can steal your admin password.  It only has an FTP or SSH connection which you use to upload your changes to the server.

#### But then how do you do cool things?

The answer is Javascript.  And now that it's 2017, Javascript has gotten to be pretty cool.

### Step 1: get Hugo and create a site.

[Hugo](https://gohugo.io) is a command-line tool.  That means you have to open up the Command Prompt to use it.  I'll show you how it's done in linux, but all of this applies to Windows too.  Go to the downloads page of Hugo and install the version for your system.  When you're done you should be able to open the Command Prompt or Terminal and type the following:

```bash
❯ hugo version  
Hugo Static Site Generator v0.19 linux/amd64 BuildDate: 2017-02-27T13:38:34+01:00
```

Now you can make a new website using the command `hugo new site [website name]`.  This creates a basic hugo site structure.  Now you need a theme.  Browse to [themes.gohugo.io](http://themes.gohugo.io) and download one, then extract it into your themes directory.  For example, if you chose the "Beautiful Hugo" theme, it should go in a folder called "beautifulHugo" inside the "themes" directory in your site.  Then you need go back to your root folder and change `config.toml` to use that theme.  You can have as many themes as you want in your themes directory, and choose between them in `config.toml`.

![hugo new site example](/.640x/images/modern_static_sites/hugo_new_site.gif)

```bash
❯ ls -l themes/beautifulhugo 
total 40
drwx------ 2 gordon gordon 4096 Apr 20 14:42 archetypes
drwx------ 3 gordon gordon 4096 Apr 20 14:42 data
drwx------ 5 gordon gordon 4096 Apr 20 14:42 exampleSite
drwx------ 2 gordon gordon 4096 Apr 20 14:42 i18n
drwx------ 2 gordon gordon 4096 Apr 20 14:42 images
drwx------ 7 gordon gordon 4096 Apr 20 14:42 layouts
-rw-r--r-- 1 gordon gordon 1140 Apr 17 05:47 LICENSE
-rw-r--r-- 1 gordon gordon 2495 Apr 17 05:47 README.md
drwx------ 5 gordon gordon 4096 Apr 20 14:42 static
-rw-r--r-- 1 gordon gordon  588 Apr 17 05:47 theme.toml
```

```toml
languageCode = "en-us"
title = "My New Hugo Site"
baseURL = "http://example.org/"
theme = "beautifulhugo"  # This should exactly match the name of the folder in your themes directory
```
Now if you run `hugo server` you can look at a preview of your new site at [http://localhost:1313](http://localhost:1313).  It should look like this because you have no content:

![new site image](/.640x/images/modern_static_sites/new_site.png)

### Step 2: Adding content and images

[Hugo has a great tutorial](http://gohugo.io/overview/quickstart/) on how to build your site and add content.  Seriously, read through it.  The awesome thing about hugo is that all content is markdown files.  Markdown makes it super easy to just write, and you can worry about presentation later.

All content goes in the `content/` folder, and the way it is organized within that folder affects where it is on the website.  Most websites, especially blogs like this one, have a `post/` category.  For example, this blog post is in the file `content/post/modern_static_sites.md`.  [Check out the raw content of this post here](https://raw.githubusercontent.com/gburgett/blog/master/hugo/content/post/modern_static_sites.md) to see an example.  All images are stored in the `static/images` folder.  Then you just reference them with the URL path `/images/my_image.jpg`.  Everything in the `static` folder actually gets copied directly to the output folder, so you can put anything you want in there.

### Step 3: Adding Javascript and CSS

You put your custom CSS and Javascript in the `static/` folder.  The trick now is to reference it.  Your theme already references some CSS and JavaScript, and if you want you can override those references.  If you name your CSS or JS files the same thing as the theme does, then your files will win.  However, then you lose the theme's stylings, which is not good.  It's better to override a layout file to include your custom CSS and JS.

Layouts are how you tell Hugo what HTML to build out of your content.  Your theme already comes with layouts though you can always add more.  Here we'll override two layouts in order to add our CSS and JS.  The "beautifulhugo" theme has two custom layout files called `head_custom.html` and `footer_custom.html` (a different theme will have different layouts, you need to crack open the files and figure out which one you want to override).  They are in `my-awesome-site/themes/beautifulhugo/layouts/partials/`.  You need to copy those to the root folder, `my-awesome-site/themes/partials/head_custom.html` and `my-awesome-site/themes/partials/footer_custom.html`.

Now open up those files and add in a reference to your scripts and css.  If you want to see a working example, [here is the file I overwrote to add in custom scripts to my blog](https://github.com/gburgett/blog/blob/master/hugo/layouts/partials/script.html).  My blog uses the hugo-uno theme, so I needed to overwrite the `script.html` file.

### Step 4: Building and hosting the site

You can host your site anywhere, from a normal host like Hostgator to even [exposing a Dropbox folder as a website](http://www.dropboxwiki.com/tips-and-tricks/host-websites-with-dropbox).  If you have an account on Github, they provide "Github Pages", which is free hosting for static sites.  [Hugo even has a tutorial on how to host using Github Pages](https://gohugo.io/tutorials/github-pages-blog/).  This is one of the great reasons to use a static site generator, you can host your website literally anywhere!

If you have an existing webserver, all you have to do is run the `hugo` command, then using FTP upload the `public/` folder to your web server.  No PHP or MySql configuration necessary!

## Now the fun part - Spicing up the Javascript

The inspiration for this post is [a new website I'm working on for CRU Albania](https://crualbaniadigital.gitlab.io).  We're using Hugo for that website too, but I wanted to do a little more with the Javascript and CSS.  Modern websites don't use raw Javascript and CSS anymore, they use preprocessors and bundlers like [Sass](http://sass-lang.com/guide) and [Webpack](https://webpack.js.org/).  So instead of writing CSS I'll be writing Sass, and instead of using Javascript I'll be writing [Typescript](http://www.typescriptlang.org/).  Now since all of this gets transformed into CSS and Javascript by pre-processors, I can still use it along with Hugo to create a completely static site.

I started with the [victor-hugo template on Github](https://github.com/netlify/victor-hugo).  This template uses [Gulp](http://gulpjs.com/) to automate the process of running all the pre-processors, and producing the output.  The [provided gulpfile](https://github.com/netlify/victor-hugo/blob/master/gulpfile.babel.js) runs Webpack on the "js" task, and Postcss on the "css" task.  The outputs of those tasks are put directly into the `public/` folder, the same place where Hugo puts its content.  The "build" task depends on those two tasks and also the "hugo" task, which calls hugo to build the site into the `public/` directory.  So simply running `gulp build` combines these pre-processors to build the static site.

[Follow along with the code on Gitlab](https://gitlab.com/crualbaniadigital/crualbaniadigital.gitlab.io)

#### Using Sass to preprocess the CSS

The first thing I did was change the css task to use Sass instead.  It also uses `cssnano` to minimize the resulting CSS.  Then it writes it out to the 'static/generated-css' directory instead of directly to public.  This way I can check it in to Git, and Hugo will copy it to the output directory when it runs.

```js
gulp.task("css", buildCss);

function buildCss(onError) {
  return gulp.src("./src/css/*.*css")
    .pipe(sass().on('error', onError || sass.logError))
    .pipe(gulp.dest('./static/generated-css'))
    .pipe(cssnano().on('error', onError || gutil.log))
    .pipe(rename({ suffix: '.min' }))
    .pipe(gulp.dest('./static/generated-css'))
  }
```

#### Using Webpack to transform Typescript into Javascript

Then I changed the webpack config to use Typescript.  The key part is using [awesome-typescript-loader](https://github.com/s-panferov/awesome-typescript-loader) to compile the typescript so that Webpack can use it.  Here's the relevant section of the webpack config file:

```json
module: {
  loaders: [
    {
      test: /\.((png)|(eot)|(woff)|(woff2)|(ttf)|(svg)|(gif))(\?v=\d+\.\d+\.\d+)?$/,
      loader: "file?name=/[hash].[ext]"
    },
    {test: /\.json$/, loader: "json-loader"},
    {
      loader: "babel-loader",
      test: /\.js?$/,
      exclude: /node_modules/,
      query: {cacheDirectory: true}
    },
    {
      loaders: ["babel-loader", "awesome-typescript-loader"],
      test: /\.tsx?$/,
      exclude: /node_modules/
    }
  ]
},
```

Notice that you put the `babel-loader` in front of `awesome-typescript-loader` in the loader chain.  This is because in this project the `tsconfig.json` file tells typescript to target the ES2015 version of Javascript, so we use babel in order to translate that version into older versions for older browsers.

The webpack config file also tells webpack to put the output file in the `static/generated-js` folder, for the same reason that the CSS goes there.

#### Preprocessing images with gulp

One thing to watch out for with a static site is your image size.  Wordpress isn't there with a convenient plugin to prevent you from uploading a huge image.  If you're not careful you can really blow up someone's mobile bandwidth with a gigantic 300 megabyte banner image.  This is important for my use case especially because other people will be writing blog posts for this website, and if they upload a huge image I want to automatically have it be resized before it's put on the web.

Fortunately there's [gulp-image-resize](https://www.npmjs.com/package/gulp-image-resize) and [gulp-imagemin](https://www.npmjs.com/package/gulp-imagemin).  These libraries use ImageMagick to resize images inside a gulp task.  I created [a separate file for the image tasks](https://gitlab.com/CruAlbaniaDigital/crualbaniadigital.gitlab.io/blob/master/gulp/image_tasks.babel.js) which does the following steps:

1. Scans for any new jpg, png, gif or svg files in `static/images/` and backs them up to `static/.original_images`
2. For all the original-size images in `static/.original_images/`:
  1. Checks if the image has already been processed, i.e. the corresponding file in `static/images/` is not the same size
  2. If it's not already been processed, runs `imageResize` and `imagemin` to compress it down to 640px wide.

After this task, the original images are stored in `static/.original_images/` and the ones in `static/images` are reprocessed and resized down to a reasonable size.  Now, since the original images are also stored on the server, we can serve them up to the user if they have a screen big enough to make use of them.  How do we determine that?  Javascript!

```js
$('img').each(function() {
  const attr = $(this).attr('src')

  if (typeof attr !== typeof undefined && attr as any !== false) {
    if (!window.matchMedia || !window.matchMedia('(max-width: 640px)').matches) {
        // This is not an iPhone, try to load the larger image

      let location = new URI(attr)
      if (location.hostname() === '' || location.hostname() === window.location.hostname) {
            // it's a locally sourced image, if it's in the /images/ directory load from /.original_images/ instead
        const path = location.path().split('/')
        if (path[1] === 'images') {
          path[1] = '.original_images'
          location = location.path(path.join('/'))
          const src = location.normalize().href()

            // preload with a detached Image element, and set it on the dom only if it succeedes.
          const $this = $(this)
          const i = new Image()
          i.onload = () => {
            $this.attr('src', src)
          }
          i.onerror = (ev) => {
            console.log('Error prefetching image ', location, ev)
          }
          i.src = src  // start loading
        }
      }
    }
  }

  return true
})
```

This little baby is in [src/js/app.ts](https://gitlab.com/crualbaniadigital/crualbaniadigital.gitlab.io/blob/master/src/js/app.ts) and runs over every `<img >` tag.  Using this line `window.matchMedia('(max-width: 640px)').matches` it checks if the current screen is wider than 640px.  If it is, then it replaces all hrefs that point to `/images/` with ones that point to `/.original-images`.  What this means is that phone screens which are less than 640px wide will only see the compressed images, while people on laptops and desktop computers will download the full image in all its glory.  This way we don't blow up the bandwidth of phone users.

#### Here's how it looks when you run Gulp to build the site
![gulp output gif](/images/modern_static_sites/gulp_output.gif)

## Conclusion

Static site generators are great, and they get even greater when you combine them with Javascript and CSS preprocessors.  Gulp is a great tool that can manage all 3, but you can really use any build system (even GNU Make) to link all these great tools together.  Plus, in the end you can get free hosting on Github or Gitlab!  So, next time you want to make a website with cool javascript functionality, use Hugo!