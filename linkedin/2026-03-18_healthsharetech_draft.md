# 2026-03-18 Healthsharetech (DRAFT)

## Hook
Crazy how much everyone's talking about AI agents transforming their work.  It's certainly transformed mine.
But I've been wondering, what does it look like to build AI agents that empower people's lives?
I've been building an AI agent with that goal in mind and have learned a lot already!

## Body
I believe that empowering users with AI is going to require specialist agents that are very good at one particular thing.
Just like you have an accountant do your taxes, and a realtor help you find a home, specialist AI agents will become essential
tools for various parts of your life.  And with LLM-assisted coding driving the cost of software down, more software can be written
to serve ever smaller niches.  Specialist AI agents serving a particular niche can be tailored and optimized more easily than generalist agents.

I also think Agents need a good deterministic rulebook and guardrails to follow.  In building Alice, the AI agent for HealthShare Technology Solutions,
I was fortunate to already have a well-built base ruleset that helps a user know what to do next based on the current state of their healthcare expenses.
The toolset I created for Alice leverages that ruleset - whenever Alice modifies the user's data, the ruleset re-runs and gives Alice a diff of what
checklist items changed.  This helps Alice to stay grounded and guides her to the most helpful outcomes for users.

Agents are also going to need to be proactive.  People don't want a chatbot interface to your website.  They want an assistant who can do things they
don't want to do.  So I gave Alice the ability to converse directly with a HealthCare provider via email or even AI-powered phone calls.  The challenge
here was authorization scope, and defending against prompt injection or probing by untrusted external entities over email.  When talking to providers,
Alice's database access is scoped to only the particular incident that the user requested help with.  Alice also has a follow-up tool that she can use
to "wake up" after some time and follow up with a provider.

Finally, you'll need to meet people where they're at.  It's hard to get users to change their workflow and open an app on a regular basis.  That's why the
primary method for talking to Alice is over email.  When you fire off an email to Alice, it feels like you're delegating work to a trusted advisor.  Fire and forget!

If you're currently struggling with the paperwork burden of a HealthCare Cost Sharing Ministry like CHM, head over to https://www.healthsharetech.com to see what Alice
can do for you.
