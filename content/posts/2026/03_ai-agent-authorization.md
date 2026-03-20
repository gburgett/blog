+++
Categories = ["AI", "Development"]
title = "Towards an Effective AI Agent Authorization Framework"
Tags = ["AI", "Agent Design", "Albers Aerospace"]
date = "2026-03-20T10:00:00-05:00"
draft = true
unlisted = true
+++

I've been mulling over this report a lot recently: https://www.thoughtworks.com/content/dam/thoughtworks/documents/report/tw_future%20_of_software_development_retreat_%20key_takeaways.pdf

Section 7 discusses security of AI agents, stating that "security is woefully behind".  Man does that hit home.  Just like everyone else, I've thought about installing OpenClaw.  But I can't see how it could possibly be safe to use.

In this blog post I want to think through what kind of granular authorization controls an AI agent needs to effectively work on your behalf.

## Background

I run Agile project management at Albers Aerospace through a self-hosted Redmine instance with several custom plugins.  I recently thought about adding a CLI over the API, allowing me to triage my backlog through Claude Code.  I very quickly got the proof of concept up and working: the CLI can create, read, update, and delete projects and stories, as well as re-order my agile board.  But the permission scope is too broad - Claude can do everything I can do.  If I want to run it in the background I need a more fine-grained permissions system.

## Thought process

I think Agent permissions are going to depend a lot on the task given to the agent as well as who the agent is talking to.  In this case the agent is always me, but as an example [Alice, the AI agent powering HealthShare Technology Solutions](posts/2026/03_building-ai-agents-that-empower/), needs to occasionally talk to healthcare providers on behalf of users.  Her permission set is different depending on who she's talking to.  For this use case, I only need to worry about the given task.

I want a permission system that is not overly intrusive, but does prompt the user when the agent does something unexpected.  I like the way that the AWS CLI uses SSO to authenticate short-lived tokens.  Can I give my CLI a long-lived read-only token, and then upgrade that token for short-lived operations on specific projects with a clear authentication prompt to the user?

## Failure modes

We've got a few problems to consider with this particular Redmine instance.  One is that some of the data within is considered Controlled Unclassified Information (CUI), and therefore should never be read by Claude.  I can however allow Codex CLI to read it when configured to connect to Azure GovCloud for inference.  So the permission set also depends on which AI agent I'm using.  I need an interface to register that beforehand.

A second problem is that I can't rely on Claude to self-report its permissions.  AI agents are notoriously eager to please and will easily hallucinate permissions it doesn't have in order to get the job done.

A final problem to consider is alert fatigue.  I need to present a clear permission check once and then let the agent run, not badger the user with constant permission gates.

This led to a permissions system idea that combines Doorkeeper with custom scope validation, allowing the CLI tool used by Claude or Codex to 1. self-register, 2. get scoped read-only permissions by default (e.g. Claude can only see non-CUI tagged resources), and 3. request short-lived token upgrades to get done what the user asked.

## Permission Scopes

Doorkeeper provides OIDC allowing a client to obtain a bearer token for future API requests.  We need to define our scopes and then create a custom parser that parses and authorizes those scopes.  The basic process is as follows:

* One-time only: User authenticates the AI agent with Redmine, performing an initial OIDC registration and obtaining a long-term API key.
    - The developer specifies via a dropdown and confirmation dialog whether this key will only be used by CUI-capable agents and it gives them access to a CUI-scoped key.  CUI-scoped keys must be refreshed more often than non-CUI keys.
* For initial research, the AI agent can read anything the user has access to.
* The AI agent then decides which projects it needs write access for, and requests a time-limited token with scope to those specific projects.  The agent is also asked to estimate the number of write operations it will need, and specify that in the key.  The key is then limited to that number plus 10% of write operations.
  - This guards against the failure mode where an AI agent autonomously decides it needs to re-write a large number of cards
* Deletion is its own special scope, with similar rules as the write operations but specifying the exact resources to be deleted
* In the authorization dialog, the user can choose to extend the requested authority for a longer period of time or unlimited number of events if needed for a long-running task.

Whenever the user instructs their agent to perform some modification to Redmine, a permission dialog pops up asking them to authorize the change, and granting the short-lived token to the agent.  The popup makes clear that the user is responsible for any changes made by the agent to the system, and that their name will appear on audit logs for operations performed by the agent.  Permission elevation events are also retained in the audit log.

## Delegated authority, not accountability

> “A computer can never be held accountable, therefore a computer must never make a management decision.”
> 
> – IBM Training Manual, 1979

This idea should pervade everything we do with AI.  If I give an AI agent permission to do something on my behalf, I am accountable even if the agent does something I didn't intend.  This is a tough balance though - keeping an AI within the defined scope of the permissions that the user wants to give it without consigning the user to "alert fatigue".

I think it's worth comparing this scenario to delegating to a human subordinate.  I want them to be able to take independent action and solve problems on their own, but if they run into "I'm not sure I should be doing that..." then they should come ask me.  Agents are unfortunately terrible at saying "I'm not sure I should be doing that...".  So we need to put stricter guardrails, but the balance is tricky.  For this particular use case, the agent should propose changes for the user to review before implementing them.  In my opinion this strikes the best balance of usability and control.

## Future extensions

This could potentially be extended to be used for long-running background agents.  Instead of opening the user's web browser, the agent could send the user a slack message with a link and a redirect URL routed through ngrok so the agent can get the code.  This would need a trusted messaging channel to avoid phising attacks.

Any other extensions you can think of?  Or criticisms of this model?
