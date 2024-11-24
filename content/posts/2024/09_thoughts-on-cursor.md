+++
Categories = ["Development"]
title = "Thoughts on Cursor"
Tags = ["Development", "AI"]
date = "2024-11-16T10:00:00-05:00"
quote = "Developers who effectively leverage AI tools will easily be 2 or 3 times as productive as other devs with equivalent experience."
+++

As AI tools continue to reshape software development, I've been particularly impressed with Cursor, an AI-powered code editor that has transformed my daily workflow. After several months of use, I want to share my experiences and observations about why this tool has become indispensable in my development process.

The most striking impact of Cursor has been the dramatic increase in my productivity - I estimate it has doubled my coding speed.
The secret sauce that Cursor has nailed is the UX around applying suggested edits back to my codebase.
The experience feels natural, almost like dictating your thoughts to a junior developer who then implements the code exactly as you envision it.

I've experienced this benefit firsthand while developing the admin interface for HealthShare Technology Solutions using Laravel and PHP. Despite my limited experience with PHP, Cursor has enabled me to efficiently build out complex features by translating my intentions into working code. I don't need to be a PHP expert - I just need to know what I want to accomplish, and Cursor helps bridge the knowledge gap.

### UX is Critical for AI Tools

This leads to my first major observation about AI-powered development tools: the user experience is absolutely crucial. Simply having access to a powerful language model isn't enough - the tool must excel at making that model's capabilities easily accessible and applicable to specific development tasks. Cursor's success demonstrates that the interface between the developer and the AI is just as important as the underlying AI technology itself.

### AI is best when the pattern already exists

Cursor's strength lies in mimicing patterns it already knows, and applying those patterns to new situations.  I found it
most productive in building new transactional email classes with corresponding blade templates and specs.  Cursor not only
knows the general "best practices" for email templates, it is also able to scan my existing templates and build new ones
that follow the same pattern.

This means that staying as close as possible to the "standard" way of doing things is crucial.  The more Cursor can leverage
the "global knowledge" stored in it's model, the more productive you will be.  Opinionated frameworks such as Rails or
Laravel will see the most benefit, and developers who organize code "The Rails Way" will be able to just hit "apply"
more frequently than developers working in codebases with lots of tech debt.

### Developers who know how to use AI will separate themselves from those who don't.

There are two equal and opposite errors developers make when they use AI: they might dismiss it as not relevant, or they
might become overreliant on it.  Those who dismiss AI will fall behind, and those that are overreliant will expose their
organizations to significant risk.  During a recent code review, I caught some AI generated code that had assumed it would
be running in a trusted context but in fact it was going to run inside an iOS app.  This code needed the production
database password to run!  We had to rewrite it as a server-side function.

Developers who effectively leverage tools like Cursor and CodeRabbit (an AI Code Review tool) will easily be 2 or 3 times
as productive as other devs with equivalent experience.  Devs who know the limitations of AI will catch AI generated issues
early, saving their organizations from significant risk and losses.  Developers who are able to hit the sweet spot will
be worth their weight in gold, and hiring managers need to begin taking that into account.

## Implications

I have effectively doubled my productivity using Cursor and other AI tools.  For salaried employees, your
negotiating power (and pay) does not necessarily increase when your personal productivity increases; the hiring managers
at the companies you're interviewing for need to believe that you are worth the money.  Typically this means your pay
really only increases with the *average* productivity increase of devs with similar resumes.  

I am thinking that I need to find a way to capture more of that productivity gain than I otherwise might as a 
salaried worker.  This likely means contracting, bidding fixed-price contracts and delivering on them with half the
effort and hours.  Or it means creating a product and finding product-market fit in half the time and effort.

I think that the world is likely to see more software produced in the future, and have an even greater need for developers.
Software products that were otherwise not viable because of the engineering effort required to create them, are suddenly
viable because with LLMs we can build them in half the time.  A host of new startups will be created that cater to
smaller and smaller niches, because the cost to cater to them has dropped.  And more code means more need for developers
who understand LLMs and, crucially, where human intelligence is still required to weigh in.

I am optimistic for the future!
