+++
showInHome = true
toc = false
title = "VoirDire App"
image = "/images/projects/voir-dire-app.png"
badges = ["React", "PWA", "Electron"]
links = [
    {icon = "fas fa-globe", url = "https://www.voirdire.app/"}
]
date = "2024-10-20"
+++

We built the VoirDire app to help our client handle jury selection electronically for his upcoming trials.  He is now
marketing the app through his network of attorneys to build out the user base.

Many attorneys still use pen and paper sticky notes to write down juror notes, including tracking responses to juror
questions during the jury selection process.  We solved the note taking process electronically, making note taking
both more robust and searchable.  It also helps attorneys appear more organized in the courtroom, where appearances
can make a difference on the margins in the outcome of a case.

The core of the app is a React frontend built with Vite and deployed as a downloadable Electron app.  My main contribution
was to extract state management into Redux using Redux Toolkit to make persistence easier.  I also implemented
Export/Import to Excel, and license management using a Redux middleware which pops up a licensing screen whenever a
user crosses their licensing limits.  I was able to accomplish all of these in significantly less time than was budgeted,
which allowed the fixed-bid project to get back on track.

Implementing the licensing modal was a particularly interesting challenge that [you can read about here](/posts/2024/10_voir-dire-licensing-modal/)

