# 2026-03-18 Healthsharetech (DRAFT)

Everyone's talking about AI agents transforming their work. It's certainly transformed mine.

But I've been wondering—what does it look like to build AI agents that actually empower people's lives, not just "augment" them?

I've spent the last 6 months building Alice, an AI agent that handles healthcare paperwork for churches leveraging HealthCare Cost Sharing Ministries. Here are 4 things I've learned about building AI that empowers users:

**1. Be a specialist, not a generalist**

Just like you have an accountant do your taxes and a realtor help you find a home, specialist AI agents will become essential tools for specific parts of your life. I believe empowering users with AI is going to require agents that are very good at one particular thing.

And with LLM-assisted coding driving the cost of software down, more software can be written to serve ever smaller niches. Specialist AI agents can be tailored and optimized way more easily than generalist agents trying to do everything.

**2. Give your agent a deterministic rulebook**

In building Alice for HealthShare Technology Solutions, I was fortunate to already have a well-built base ruleset that helps users know what to do next based on the current state of their healthcare expenses.

The toolset I created for Alice leverages those rules. Whenever Alice modifies the user's data, the ruleset re-runs and gives Alice a diff of what checklist items changed. This helps Alice stay grounded and guides her to the most helpful outcomes for users. No hallucinating about what needs to happen next.

**3. Make your agent proactive**

People don't want a chatbot interface to your website. They want an assistant who can do things they don't want to do.

So I gave Alice the ability to converse directly with healthcare providers via email or even AI-powered phone calls. The challenge here was authorization scope and defending against prompt injection or probing by untrusted external entities over email. When talking to providers, Alice's database access is scoped to only the particular incident that the user requested help with. She also has a follow-up tool that lets her "wake up" after some time and follow up with a provider without the user having to remember.

**4. Meet people where they're at**

It's hard to get users to change their workflow and open an app on a regular basis. That's why the primary method for talking to Alice is over email.

When you fire off an email to Alice, it feels like you're delegating work to a trusted advisor. Fire and forget!

---

If you're currently struggling with the paperwork burden of a HealthCare Cost Sharing Ministry like CHM, head over to https://www.healthsharetech.com to see what Alice can do for you.

Or if you're building similar proactive agents, I'd love to compare notes.  DM me!
