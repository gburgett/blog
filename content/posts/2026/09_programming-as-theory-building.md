+++
Categories = ["AI", "Development"]
title = "Theory Building with AI"
Tags = ["AI"]
date = "2026-06-24T10:00:00-05:00"
draft = false
unlisted = false
quote = "How does an AI gain an understanding of your codebase?"
+++

# What is the act of programming?
My team and I [went back to first principles](./05_scrum-is-broken) earlier this year.
And I went back to the old masters: Brooks, Naur, Djikstra.  I was seeking to re-learn the essence of Software Engineering from those who had thought about the
problem in the beginning.

If the act of programming is no longer typing symbols into computer code, then what is it?  I think Naur has a great definition in his paper, ["Programming as Theory Building"](https://pages.cs.wisc.edu/~remzi/Naur.pdf).

> ...programming properly should be regarded as an activity by which the programmers form or achieve a certain kind of insight, a theory, of the matters at hand.  
> - Naur, Programming as Theory Building, 1985

He goes on to discuss the ways this differs from the prevailing view of programming as an activity by which the programer produces a program.  A key insight is that
most bugs in software are traced to *inadequate understanding* - and that the program text and its documentation are *insufficient* as a carrier of the most important
*design ideas*.

## What does an AI do when it encounters a codebase?

Large language models in coding harnesses, such as Claude Code, are currently limited by their context size.  Thus they approach each fresh session from a clean slate -
no preexisting *understanding* of the *design ideas* is present in the model's weights, and they must *reconstruct the theory of the program from scratch* in each session.
There have been many workarounds to try to ease this process:
- AGENTS.md / CLAUDE.md files
- Skills and skill directories
- RAG or language graph guided search over the corpus

All of these workarounds, and all of the searching that the agent does, are attempts to encode in the model weights the relevant theory of the program prior to generating any
code.  This is a fundamental limitation of the current generation of LLMs.  It may be removed in the future but we must work now.

## How do we best assist the agent in discovering the theory?

The first key is documentation.  Relevant documentation must be *present* before it can be discovered.  CLAUDE.md is the easiest place to get started with documentation, but too
much in that layer can lead to context pollution.  The *why* of the system must be encoded in a discoverable place.  Docs folders, docstring comments, etc. are extremely helpful for
communicating the *theory* of the program to the agent at the relevant time.

Unfortunately it is easy for the agent to simply miss this documentation.  If it doesn't execute the necessary tool with the right parameters, the relevant documentation may never
be returned by grep, find, or whatever other agentic search tool is present in your harness.  We cannot prevent this outcome, we can only minimize it.

The secret is *automated deterministic validation* that is tied back to the *theory* of the program.  If an agent writes code that violates the theory of the program, your test suite
should not simply fail, it should fail with a message *communicating the tenet that was violated*.  For this reason I am a huge fan of using Cucumber to document and crucially *enforce*
all your acceptance criteria.  Here's an example from my most recent AI-engineered app, [plantrify](https://plantrify.com):

```gherkin
Feature: Sending the list to Kroger
  As a busy housewife
  I want the week's shopping list put into my Kroger cart
  So that I can pick it up without retyping anything

  The sandbox has no network, by two independent controls, and neither of them
  is weakened here. The Kroger call is made by the server, outside the sandbox,
  from a list the sandbox produced. That is the whole reason two tools exist
  beside the three that are the sandbox: a tool exists only when the sandbox
  cannot do the job by construction, and the network is the only such job.

  KROGER'S PUBLIC CART IS ADD-ONLY. There is no read, no update and no delete,
  so the meal planner can never say what the cart holds — only what it sent.
  Every scenario below is written around that, and the assertions read what was
  sent rather than what arrived.

  Nothing is ever chosen for the household. `filter.term` on "boneless chicken
  thighs" returns noise, so the tool writes down the candidates and stops. The
  agent chooses by deleting the lines it does not want, which is an ordinary
  edit to an ordinary markdown file.

  Background:
    Given I have recorded the recipe "Chicken Tacos" serving 4 with the ingredients:
      | quantity | unit | item                    |
      | 1.5      | lb   | boneless chicken thighs |
      | 8        | oz   | shredded cheddar        |
      | 12       |      | corn tortillas          |
    And I have planned dinner on "2026-08-25" with the recipe "Chicken Tacos"

  @core
  Scenario: Sending the chosen products to my cart
    Given my Kroger account is connected
    And I shop at "Kroger On the Rhine" for pickup
    And Kroger sells at my store:
      | search           | upc           | description                          | size | price |
      | shredded cheddar | 0001111050158 | Kroger Sharp Cheddar Shredded Cheese | 8 oz | 2.00  |
    And the shopping list for "2026-08-25" to "2026-08-31" has been matched against Kroger
    When I send the shopping list to my Kroger cart
    Then my Kroger cart was sent:
      | upc           | quantity |
      | 0001111050158 | 1        |
    And the meal planner says the cart cannot be read back
    And the shopping list records what was sent
```

These scenarios are executable - Cucumber turns them into tests, and when the test fails the specific "Then" assertion inside the feature file is returned to the agent.  The agent
reads the feature file and discovers the *theory* of the program - *why* is it important that the shopping list records what was sent, it is important because Kroger's public cart API
is add-only.

Documentation is no longer simply important, it is required.  Software engineers who master the skill of documentation will have much greater success working with agents than those who
do not.

## Your attempts to communicate the theory will fail

Naur's other observation is that the theory of the program is only *incompletely* transmitted through code and documentation.  Code and documentation are lossy mediums, hence the need
for active communication between the current maintainers and those originally responsible for developing the program.  In the agentic world, this is the role of human oversight and review.
*You* possess the core theory of the program, not the AI. *You* understand the why, *you* understand the way it fits into the larger whole, and *you* understand the value of the program
that you are creating.

On our team, we settled on reviewing the agent's work at the plan level prior to producing code, not at the code level.  This allows us to detect areas where the agent's understanding is
incomplete and correct it.

In another recent example, we are porting the mobile app experience for [Healthshare Technology Solutions](https://healthsharetech.com) to a native app using Expo.  We created a design,
and exported it to Claude, then asked Claude to choose a UI toolkit for us.  We gave it a constraint that we should be able to modify color scheme and fonts in order to white-label our
app for clients.  When it wrote the Architecture Decision Record, I noticed this line:

> The UI kit must be able to change color scheme and branding at runtime without a recompile.  This eliminates more than half of the toolkits from the trade study.

I stopped the agent and corrected its theory: no, that is not a requirement.  Each partner app will be deployed as its own app to the app store.

## Where does that leave us?

Your job as a programmer is now *communication*.  This was always the case working on any decently sized team, but is now true even for the solo dev.  You must be able to clearly articulate
your thoughts and your process or your agent will produce an unmaintainable mess.  You must *engineer* the validation systems that communicate the *theory* of the code back to the agent
just-in-time.  Fundamentally this is what engineering is: communicating solutions to hard problems in a way that they can be realized, either by a machine or another person.

Don't skimp on this responsibility and you will benefit greatly.