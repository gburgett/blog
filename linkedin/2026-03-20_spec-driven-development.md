# 2026-03-20 Spec-Driven Development (posted 2026-04-03)

I've been coding with AI agents for a while now, and I kept hitting the same bottleneck: me.

Every time Claude generates code, I need to review it. Every time it implements a feature, I need to verify it works. I'm the human in the loop, slowing everything down.

So I've been experimenting with a question: Can I let an AI agent run for 8 hours, implement a complex feature, and come back to code that's secure, well-tested, and correct - without reviewing every line?

The answer: spec-driven development with Cucumber (yes, that BDD tool from 2010).

**Why this works:**

Cucumber scenarios are perfectly sized for LLM context windows. Each step is atomic - typically 50-100 lines of implementation. The AI doesn't need to understand your entire system, just one scenario at a time.

The user story lives alongside the acceptance criteria. When a test fails during a long AI coding session, the agent gets re-injected with business context, not just a stack trace. This prevents the classic AI mistake of "fixing" a failing test by changing the test.

**What I've built with this:**

1. Extracted and enhanced a Rails microservice - 2 hour autonomous run, came back to working code with full integration test coverage

2. Comprehensive firmware integration tests for our Albers Aerospace SC-410 camera - 8 hour run implementing 16 scenarios, including one that required a full WebRTC peer connection just for testing

3. Dynamic data entry replacing manual form with approval process and analytics for managers supporting our Albers Industrials division - This one I built from first principles, translating spoken requirements into acceptance criteria before letting Claude loose on a 4 hour run.

**The workflow:**

I write high-level Cucumber scenarios describing what the system should do. No implementation details, just behavior. Then I tell Claude: "Never modify feature files. Implement all scenarios. Keep iterating until all tests pass."

Then I walk away.

When I come back, I review architectural decisions and API contracts, not nil pointer bugs.

**What this doesn't solve:**

You still need principal/staff-level thinking for architecture and data structure design. Writing good scenarios requires understanding what behavior actually matters.

But it lets AI handle senior engineer-level implementation while I focus on system design.

**The catch:**

AI agents give up when things get hard. Claude will sometimes leave TODO comments or declare victory before tests actually pass. I'm still figuring out how to keep agents iterating longer without human intervention.

---

Anyone else experimenting with BDD tools for AI-driven development? I'd love to compare notes on what's working.

Full writeup on my blog: https://gordonburgett.net/posts/2026/03_spec-driven-development/
