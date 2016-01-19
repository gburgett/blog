+++
date = "2014-12-14T13:52:12-06:00"
draft = false
title = "Creating a blog"
Categories = ["Development", "Hosting"]
Tags = ["Development", "hosting"]

+++

### Well, here it is.

I've been wanting to create a blog for a while.  I don't know what it will look like in the future, or how often I'll update it, but as I sit here writing it it's kind of cathartic.  It would be good to get some thoughts out there, and if anybody reads it that's a bonus.

I want to talk about anything and everything on this blog.  I'll delve into my work, hopefully some of these pages will be useful when another developer types some obscure error code into google.  I'll discuss my faith, hopefully that could spark some interesting discussion.  I'll discuss the important stuff that happens in my life, hopefully someone might find it interesting.

I guess for my first post I'll just talk about how I went about creating this blog.  I chose [Hugo](http://gohugo.io/) because we've been playing with Go at work and it looked neat.  It's already been pretty simple to set up, I might be able to actually get this thing hosted within the next hour.  I'm also trying to learn my new macbook pro, which work gave me.  I've never worked with a mac before but I know a bit of linux, and I've found the command line to be pretty intuitive.

It was pretty easy to set up, I just did the following:

1. `hugo new site ~/projects/hugo/myblog`
2. `cd ~/projects/hugo/myblog`
3. `hugo new about.md`
4. `hugo new post/first.md`

All this text is inside 'first.md', which I then renamed to 'creating a blog.md'.  The URL after Hugo generates the html page is 'http://localhost:1313/post/creating%20a%20blog/'.  Easy peasy.

I grabbed the themes using `git clone --recursive https://github.com/spf13/hugoThemes themes`, then ran the server using the 'hugo-uno' theme:
`hugo server --theme=hugo-uno --buildDrafts --watch`

I had to update the 'config.toml' file to have the links to my blog and the correct title and description, here's what I ended up with:

```
baseurl = "http://yourSiteHere"
languageCode = "en-us"
title = "first things first"
author = "Gordon Burgett"


[indexes]
	category = "categories"
	tag = "tags"
[Params]
	AuthorName = "Gordon"
	github = "gburgett"
	email = "***planning to obfuscate this somehow***"
	description = "A blog about whatever crosses my mind, ordered by importance."
```

I wanted to obfuscate my email adress to avoid spam.  Unfortunately the hugo-uno default sidebar just uses a mailto link.  Here's the HTML inside social.html:

```html
{{ if .Site.Params.email }}
<!-- Email -->
<li class="navigation__item">
    <a href="mailto:{{ .Site.Params.email }}" title="Email {{ .Site.Params.email }}"> <i class='fa fa-envelope-o'></i> <span class="label">Email</span> </a>
</li> {{ end }}
```
So I overrode the social.html by copy-pasting it to myblog/layouts/partials/social.html, and removed the mailto: and title.  I added some javascript to only write the mailto when you click on the mail link.  I put the javascript inside static/js/custom.js, and included a link to it inside an overridden script.html:
```javascript
$(document).ready(function(){
	$('#email').click(function(evt){
		evt.preventDefault();

		var e = 'gordon' + '.burgett' + '@gmail' + '.com';
		var link = $('<a>').attr('href', 'mailto:' + e).text(e);
		$('#email').empty();
		$('#email').append(link);
		$('#email').off();
	})
});
```
Note: if you don't have well-formed HTML in your script.html, then Hugo basically just forgets to include it and doesn't tell you.  That tripped me up for about 15 minutes.

I also added syntax highlighting using [highlight.js](https://highlightjs.org/usage/) by including this in the script.html:
```html
<link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/highlight.js/8.4/styles/default.min.css">
<script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/8.4/highlight.min.js"></script>
<script>
  hljs.initHighlightingOnLoad();
</script>
```

The hardest part will be getting a good background image, but I can put that off till later.  I guess my next post will be about the adventure of hosting this thing.