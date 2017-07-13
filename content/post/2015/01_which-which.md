+++
Categories = ["Development", "GoLang"]
Description = ""
Tags = ["Development", "golang"]
date = "2015-01-06T22:49:08+01:00"
menu = "main"
title = "which which?"
aliases = [
  "/post/which which/",
]

+++

I'm using [locomotivecms](http://locomotivecms.com/) for a project I'm working on, and it uses [ImageMagick](http://www.imagemagick.org/) for resizing pictures on the fly.  The [standard instructions](http://doc.locomotivecms.com/get-started/install-wagon#windows) say to use the bitnami Ruby stack installer to get everything you need in a nice neat bundle.

That worked for me for a while, until I needed to update the version of ruby I'm using.  So, I went through the long and painful process of uninstalling the ruby stack, installing each component individually, identifying and correcting a ton of minor problems, and finally squashed the last bug by writing this program.

Essentially, the command `bundle exec wagon serve` looks up the location of ImageMagick's `convert.exe` program by invoking `which convert`, which only works on linux systems, or if you're using a port like unxutils.  So, once I got ruby working and was self-hosting my site for development, none of my resized images were showing up.  The console showed this error message:

```sh
which: no convert in (...;C:\Program Files\ImageMagick-6.9.0-Q16;...)
```

So GNU which v2.4 for some reason can't find convert.exe inside the ImageMagick install.  After playing with it, I found that `which convert.exe` worked, but `which convert` didn't.  Very lame.

###  ♪ Cause I still haven't found what I'm looking for... ♪

The next couple hours were an adventure in dirty hacks.  First I tried removing GNU which off the path, and using MSYS which.  MSYS which is a shell script, so I made a batch file wrapper to invoke it using MSYS sh.  That could find the file, but it resulted in a unix-style path: `/c/Program Files/ImageMagick-6.9.0-Q16/convert`.  Since wagon is feeding this path directly into a `cmd /c` invocation, it wasn't good enough.

After unsuccessfully playing with writing a batch script to invoke `where`, I decided to write a clone of `which` in go.  This accomplished two objectives: fix my locomotivecms install, and learn go.  The requirements are very simple, the command `which convert` should return a string that can be passed to `cmd /c` to invoke ImageMagick's convert.exe.

It took me 2-3 hours to do, but here is my first complete go program! https://github.com/gburgett/which