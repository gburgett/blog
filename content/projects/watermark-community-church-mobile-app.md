+++
showInHome = true
toc = false
title = "Watermark Community Church App"
image = "/images/projects/wm-app-figma.png"
badges = ["Outsourcing", "Rock Mobile"]

date = "2024-12-02"

kicker = "Case study · Outside team, no internal mobile engineers"
dek = "A congregation-scale app, delivered by an agency, owned by a team of one. The interesting work was never the code."
ctaTitle = "Sitting on this side of an outsourced build?"
ctaBody = "I've picked vendors, run the relationship end to end, and cleaned up after the ones that went badly. Happy to compare notes on yours."

facts = [
  { k = "Organization", v = "Watermark Community Church" },
  { k = "My role", v = "Product owner and delivery oversight" },
  { k = "Build team", v = "External agency, iOS and Android" },
  { k = "Outcome", v = "Shipped, and still running" },
]

related = [
  { tag = "AI agents", title = "Building AI agents that empower", body = "Design principles for a customer-facing agent people actually trust.", href = "/posts/2026/03_building-ai-agents-that-empower/" },
  { tag = "Knowing when not to", title = "A data import I kept boring", body = "Where the model stopped and ordinary code took over.", href = "/posts/2024/11_neighbor-solutions-import/" },
  { tag = "Ways of working", title = "Scrum is broken", body = "What happens to planning when a sprint finishes in an afternoon.", href = "/posts/2026/05_scrum-is-broken/" },
]
+++

We needed a mobile app for a congregation of thousands. We had no mobile engineers, no realistic path to hiring any, and a budget that would cover roughly one good agency engagement — once. Everything after that decision was about protecting the one shot.

## The real constraint was attention, not money

An agency will build what you specify. What they will not do is notice that the thing you specified is not the thing your people need. That noticing is the client's job, and it is a full-time job that nobody had time for.

So I compressed it. Rather than a long requirements document, we agreed on a short list of things a member should be able to do on a phone in under thirty seconds, and treated everything else as out of scope until proven otherwise.

> Scope discipline is the entire deliverable when someone else is holding the keyboard.

## What I actually did each week

- Reviewed every build against the thirty-second list, not against the spec
- Sat in on the agency standup once a week so surprises surfaced early
- Made the call myself when a feature was worth cutting, in writing, same day
- Kept one document that said what we were building and why — the only artifact anyone read

## Where it nearly went wrong

Halfway through, the agency proposed a rewrite of the notification layer that would have been technically better and cost us six weeks. It was the right engineering instinct and the wrong decision for the situation: we had no internal team to benefit from the cleaner architecture later.

{{< callout "The call" >}}
We shipped the simpler version, documented the tradeoff, and left the rewrite as a known cost for whoever picks it up. Four years later nobody has needed to.
{{< /callout >}}

## What I take from it

Most organizations at this size don't lack engineering capacity — they lack someone with the standing to decide, quickly, on behalf of the business. That role does not require a full-time hire. It requires someone who has been on both sides of the contract.
