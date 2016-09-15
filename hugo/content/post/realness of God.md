+++
date = "2014-12-16T22:20:34-06:00"
draft = false
title = "The Realness of God"

+++

My friends and I were discussing christian music last night.  The main line of discussion was the lack of realness & relevance of most christian songs.  Most of them end up a bit like this:

<iframe width="640" height="480" src="//www.youtube.com/embed/GhYuA0Cz8ls" frameborder="0" allowfullscreen></iframe>

When we turn worship leaders into recording artists, we get worship songs.  Worship songs are great for "worship" (i.e. that thing we do on Sunday mornings), but the problem is that in reality, _everything is supposed to be worship_.

This was brought home for me today when I was listening to a reading of the poem [The Calvinist](http://www.desiringgod.org/calvinist) by John Piper.  A verse in the middle of that poem echoes the same sentiment

> See him at his meal,
> Praying now to feel
> Thanks and, be it graced,
> God in ev’ry taste.

God in ev'ry taste.  God is in every bite of our food.  Sounds a bit pantheist. Yes, but it's so much more.  The problem with pantheism is that the god of pantheism is limited to creation.  The beauty of Christianity is that the God who created the universe _indwells every inch_.  Because of the reality of that indwelling, every act that we perform as redeemed men and women while we exist in this created realm is an act of worship towards our creator.

Back to christian music.  The problem with "worship" music is that too much of it focuses too much on what Sproul called the "otherness" of God, that quality of His Holiness which is transcendent.  It is intended to produce a feeling in the "worshipper", bringing them to an emotional climax towards something that is outside the realm of their everyday experience.  An emotional connection towards a thing that is completely transcendent is not much different than an emotional connection towards an imaginary friend.

"Worship" music can also fall into another category, one that's less emotion and more theology.  I definitely appreciate it more than the first category.  The problem is that theology is also completely transcendent.  Here's a good example: 

<iframe width="640" height="480" src="//www.youtube.com/embed/xhMPOieCMa0" frameborder="0" allowfullscreen></iframe>

God did not present Himself to us as an emotional experience.  He also didn't present Himself to us as a set of axioms from which we can derive theological principles.  He put on flesh and became a man.  He stepped down into the real world and lived life with us.  Down here in the everyday, real world we don't deal in emotionalism, nor in theology.  The real world is conflict, pain, suffering, toil, distraction.  God doesn't take any of that away, at least not yet.  Instead He adds to it: love, joy, peace, patience, kindness, goodness, self-control.  That's what's real.  Where are the songs that have all of that?

Secular songs know what the real world is like.  Pop is full of pride, envy, fleeting pleasures, conflict, pain, and distraction.  Rap is full of hopelessness, despair and pride with a capital P.  And that appeals to the lost because it's real.  It's what we all experience at varying points of our lives and in varying amounts.  Christian music will never appeal to the masses until it has that realness.

The best we have right now in my opinion is Christian Rap.  Many of them know about the gritty reality of suffering and it shows through in their music.  And it's appealing to non-Christians in a way that "worship" music never will be.  The mainstream Christian music industry could learn from those guys, who themselves are learning from Jesus, who stepped down into our grit and grime and shared in our sufferings with us.  And we can stop supporting the "christian" music industry until it figures that out.

---

I put together a deploy script, here it is:

```bash
#! /bin/bash

hugo --baseUrl="http://www.gordonburgett.net"
cd ./public
scp -i $1 -r ./ ec2-user@gordonburgett.net:/var/www/html
```

Notice I don't have to specify `--theme`, that's cause I put `theme="hugo-uno"` inside the config.toml file.

Now deploying a new page is as simple as `./deploy.sh ~/.ssh/macbook.pem`!