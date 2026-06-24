+++
Categories = ["AI", "Development"]
title = "Scrum is Broken"
Tags = ["AI"]
date = "2026-06-24T10:00:00-05:00"
draft = false
unlisted = false
quote = "What does Agile look like when the cost of writing code trends to zero?"
+++

# Scrum is broken.

I thought I knew what Agile looked like.  2-week sprints, story points, daily standups.  I ran that cadence at my last job.
But something changed with Opus 4.7.  Now, once we've groomed the cards and defined the sprint, everything is done within a day.  
Doesn't matter how many cards we throw into a sprint, we just fire up more parallel agents.

![everything's made up and the points don't matter](/images/2026/everythings-made-up.webp)

So how do you manage your team when the cost of writing code trends to zero?  What do your software engineers do between prompts?
On our team, we went back to first principles.

## The Agile Manifesto

> We are uncovering better ways of developing
> software by doing it and helping others do it.
> Through this work we have come to value:
> 
> - Individuals and interactions over processes and tools
> - Working software over comprehensive documentation
> - Customer collaboration over contract negotiation
> - Responding to change over following a plan
> 
> That is, while there is value in the items on
> the right, we value the items on the left more.

Scrum is an attempt to implement the Agile manifesto, predicated on the assumption that software implementation takes the bulk of the time.  That's no longer the case.
When a process no longer works for your team, value Individuals and Interactions instead.

## Lean Software Development Principles

- Eliminate waste
- Amplify learning
- Decide as late as possible
- Deliver as fast as possible
- Empower the team
- Build integrity in
- Optimize the whole

The scrum ceremonies were always waste, but they were necessary waste.  Are they still necessary?  What do we fall back on?

## Where we landed

Through reevaluating our process based on these principles, we settled on prioritizing the following three principles:

1. Empower the team to own the complete life cycle of a system or subsystem
2. Amplify learning by shortening cycle times
3. Eliminate waste by reducing middlemen in communication

![Whiteboard output](/images/2026/whiteboard.jpeg)

We chose to view each team member as a product owner over a specific system or subsystem, managing a team of agents to complete the actual implementation.
The goal of each software engineer is to spend as much time as possible at the top of the systems engineering "V", defining the concept and validating the result.
This requires the software engineer to more directly interface with the stakeholders and take on more of the product owner duties.  In the context of internal
business process automation and corporate AI transformation, software engineers need to come out of their caves and have regular meetings with other teams to identify
pain points, groom those problem statements into user stories, and exercise judgement to choose what is worth working on.

The speed of implementation using AI enables much quicker cycle times.  When "Lean Software Development: An Agile Toolkit" was written, 2-weeks was chosen as the ideal sprint length
because it was *fast*.  If they could have gone faster, they would have.  This past month, one of my software engineers was running *2-day sprints*.  He had 2x a week meetings with stakeholders
and was showing *new working features at every meeting*.  This enabled him to learn the business needs at a much quicker pace than we could have if we kept it at a 2-week sprint.  As a consequence,
our team chose to de-couple and run independent sprints based entirely around the availability of the stakeholder.  If the stakeholder can meet monthly, you have a monthly sprint cadence.  If they're available
twice a week, you run 2 sprints a week.  We turned our team Agile board into a Kanban board to reflect the disconnected nature of our sprints.

This speed means the traditional gate of having a product owner control the inputs to the sprint is now the bottleneck.  By the time the product owner can write a fully-fleshed-out issue card complete with acceptance
criteria, the AI can do the implementation.  So the product owner has to shift into sharing that responsibility with the developer.  The PO can no longer be a middleman but has to become a coach - helping the engineer
to see the needs and build the requirements together instead of controlling that process.

## What then does the manager do?

As a software engineering manager, the highest and best use of my time is to empower the team and ensure they are resourced effectively to succeed.  A derivative goal is reporting effectively about productivity and roadmap
to senior leadership.  My role nowadays mostly involves interfacing with IT and senior leadership to provide effective tooling to my team, managing risk, and keeping abreast of deadlines and manpower to avoid burnout.

### 1. Providing effective tooling

The software engineering manager is best positioned to own the internal story around the value of AI token spend and tooling.  I'm close enough to my team's work to see the value that they're generating from AI, but
also have the business sense to understand the overall value of any particular program to the bottom line.  A 50% velocity improvement does not necessarily translate to 50% revenue increase or 50% cost reduction.
Knowing those metrics and telling that story enables me to define an effective budget for my team and help them to stay aligned with it.

### 2. Managing Risk

On our team we've reduced communication overhead by subdividing systems even further.  We went from a 2-pizza team to a 2-man team - one lead, and one second.  The Lead's job is to interface with the stakeholders,
define requirements (with Product Owner support where available/needed), and validate the result.  The Second's job is to approve implementation plans, asking intelligent questions to always link implementation back to
stakeholder requirements.  Additionally, the Second needs to be ready to step in if the Lead goes on vacation or wins the lottery.  This is the primary risk that needs to be managed.

The other risks include schedule and budget risk.  Most of our team is assigned to 2 (or more) programs, and only spends 1/2 or 1/4 of their time on any particular system.  It's my job to tell them how much time to spend
on each, taking into account deadlines and budget.  If a program is at risk of missing a deadline, I will focus my efforts on removing obstacles or improving cycle times, *not* adding more developers which rarely speeds
things up.

### 3. Reporting & Metrics

The biggest challenge is now productivity metrics.  We used to be able to measure velocity in terms of story points, but now the complexity of a task is no longer an accurate predictor of how much *developer attention*
is required to complete it.  A more complex task simply justifies turning up the reasoning effort or switching to a more powerful model, not necessarily spending more developer hours on it.

We still don't have an answer for this, but we do have a few ideas:

1. Estimate and measure the number of *stakeholder interactions* and go-back cycles needed to complete a high-level requirement.  
   Rather than estimate at the issue level, estimate at the epic level.

2. Estimate and measure the *research hours* that go into clarifying a requirement.
   Track research spikes as cards in your issue tracker and ask your Lead and your Second to estimate those together.

3. Measure the *tokens used per stakeholder request* and train an LLM classifier from your historical data to predict new tasks.
   This is still a pipe dream for us, but I believe that one day AI estimation will end up more accurate than human estimation for tasks and timelines.

## The future is murky

Things are still shifting faster than we can adjust.  AI models and agent harnesses continue to improve, and the "cyborg" model of working is not necessarily the future.  The most important thing to do in times of
significant change is to develop adaptive capacity.  When what you've done in the past is no longer working, be ready to reevaluate from first principles, understanding the strengths and weaknesses of your team.
