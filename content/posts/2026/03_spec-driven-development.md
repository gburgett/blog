+++
Categories = ["AI", "Development"]
title = "Pushing Claude Code Further with Spec Driven Development"
Tags = ["AI", "Development", "Albers Aerospace", "Claude Code"]
date = "2026-03-20T10:00:00-05:00"
draft = false
unlisted = false
+++

# The Problem I'm Trying to Solve

I've been coding with AI agents for as long as they've been generally available, and I keep running into the same bottleneck: me. Every time Claude generates code, I need to review it. Every time it completes a feature, I need to verify it actually works. Every time it runs tests, I need to check if the failures are real bugs or hallucinations. I'm the human in the loop, and I'm slowing everything down.

Here's what's been bugging me: Is there a way to let an AI agent run for hours through multiple compaction cycles, implement a complex feature, and come back to a result that's secure, well-tested, and correct - without me having to review every single line of code? What if I could just review the high-level decisions and trust that the implementation details are solid?

This is still an unsolved problem, and most of the advice I've read misses the mark:

- **"Review your test cases"** - Great, but how do I know which tests matter when the AI named them `test_001` or `test_bug_fix_2935`? What's the signal in all that noise?
- **"Shift left, review during planning"** - This helps with architecture but completely misses LLM hallucinations. An agent can perfectly understand what you want and still generate subtly broken code.

LLMs are genuinely good at certain things: recognizing patterns, writing small sections of code from scratch, refactoring when you give them guardrails, summarizing information. The trick is context management - keeping the right information in the AI's working memory at the right time.

What I need is a way to:
1. Break requirements into small, context-window-friendly chunks
2. Automatically verify each requirement as it's implemented
3. Keep the "why" close to the "what" so the AI doesn't lose the plot
4. Make it obvious during code review what actually matters

This post is me working through an experiment that's showing promise. I'm combining some old ideas about behavior-driven development with new realities of AI coding agents, and the results have been surprisingly good.

# Where Does the Rigor Go?

I recently read [this ThoughtWorks report on the future of software development](https://www.thoughtworks.com/content/dam/thoughtworks/documents/report/tw_future%20_of_software_development_retreat_%20key_takeaways.pdf), and a few observations jumped out at me:
- Spec-driven development needs new tool formats
- Traditional user stories are too vague for AI agents
- TDD produces dramatically better results with AI coding agents

If you've been working with AI coding agents for a while, these probably feel familiar. The question is: how do we actually solve them in practice?

## An Old Tool, A New Context

About a decade ago, when I was a mid-level developer at GDSX (later acquired by Concur, then SAP), I discovered [Cucumber](https://cucumber.io/) and got really excited about it. The promise was music to my developer ears: business stakeholders write acceptance criteria in plain English, I get to just bang out the code, and in the end I get executable documentation that verifies the system works as intended.

I was naive enough to print out a set of Cucumber specs and show them to our CEO, thinking she'd appreciate that our feature requirements were both human-readable and machine-verifiable. She politely nodded and moved on - she was operating at too high a level to really review the feature descriptions. When I realized the business folks weren't going to write specs for me, I gave up on Cucumber. The pain of implementing step definitions across multiple files and tracing scenarios through the codebase wasn't worth it when I could just write self-contained RSpec tests.

Fast forward to a few weeks ago. I'm discussing one of our services with the CTO at Albers Aerospace, and he asks: "If we had to recreate this service from scratch, how would we even know what all the requirements are?"

That question hit me hard. Our requirements were scattered across hundreds of closed Jira tickets and lost Claude Code prompts. We'd built the system iteratively, feature by feature, but we had no single source of truth for what the system should actually do. The requirements should live in the repo, not in archived project management tools.

That conversation brought Cucumber back to mind, but with a completely different context. The reason I'd abandoned it before - the tedious work of implementing step definitions and connecting scenarios across multiple files - is exactly the kind of work AI agents excel at. An AI doesn't care if it has to implement the same pattern 50 times. It doesn't get bored. It can iterate over implementation details far longer than I can.

Here's why Cucumber is well-suited for AI agent context management:

**Individual steps are atomic and bounded.** Each step is a single-line sentence that defines one specific behavior. In practice, implementing a step definition rarely requires more than 50-100 lines of code - well within an LLM's sweet spot for code generation.

**Steps compose into verifiable scenarios.** The AI doesn't need to understand the entire system at once. It just needs to understand one scenario at a time, implement the missing steps, and verify that scenario passes. This matches how LLMs actually work best - focused, bounded tasks with clear success criteria.

**User stories provide context alongside scenarios.** The Gherkin format puts the "As a... I want... So that..." user story in the same file as the acceptance criteria. When a test fails during a long-running agent session, the AI gets re-injected with the business context, not just a stack trace. This is huge for preventing the agent from "fixing" a failing test by changing the test instead of fixing the bug.

**Acceptance Criteria provide a useful framework for defining what you want.**  The actual hardest problem in computer science - communicating what you actually want the software to do for you.  As Director of External Technology Development at Watermark Community Church, I performed a lot of product owner responsibilities and appreciated the Gherkin framework of "Given... When... Then..." to clarify my thinking.  It's a useful mental framework in addition to becoming an executable verifiable scenario.

## What This Actually Gets You

**Clear boundaries in code review.** I tell the AI agent: "Never modify feature files. Only implement step definitions and application code." This creates a bright line in code review. If I see a modified feature file in the diff, I know the agent tried to change the requirements instead of meeting them. That's a red flag that needs human review.

**Long-running autonomous work.** With this setup, I can tell Claude: "Implement all scenarios in the features/ directory. Keep iterating until all tests pass." Then I can walk away. The agent has clear success criteria (all scenarios green) and clear constraints (don't modify the .feature files).

**Better failure recovery.** Here's where it gets interesting. When an agent is working on Feature A and accidentally breaks a test in Feature B, a traditional test failure just shows a stack trace. The agent often "fixes" this by modifying the test. But with Cucumber, the failing scenario comes with the user story attached. The AI sees:

```gherkin
Feature: Online Status Report
  As an agent,
  I want to see a timestamped status report recording when the camera came online
  So that I can analyze PIR trigger frequency and battery usage
```

Then the failing scenario. This context helps the agent understand whether the failure is a regression (the feature should still work) or expected (maybe Feature A intentionally changed this behavior). The "why" gets re-injected automatically at the moment it's needed.

## Two Experiments

I've been testing this approach on two different projects, and the results have been encouraging.

**Experiment 1: Rails App Feature Extraction**

I needed to extract a subset of features from one Rails application and package them as a standalone microservice.  Here's what I did:
1. Created a new Rails app: `rails new feature-service`
2. Told Claude: "Copy the authentication, organization management, and user invitation features from the main app"
3. While Claude was working on that, I wrote Cucumber feature files describing the new behavior I wanted (API endpoints and user views that didn't exist in the original)
4. Once the copy was complete, I told Claude: "Install Cucumber and implement all scenarios in features/"
5. Walked away for about 2 hours

When I came back, all scenarios were passing. The extracted features worked, the new features were implemented, and everything had integration test coverage. I still reviewed the code, but I was reviewing architectural decisions and API contracts, not hunting for nil pointer bugs.

**Experiment 2: Camera Firmware Integration Tests**

This one's more complex. We're about to ship revision 2 of our SC-410 camera hardware with a complete firmware rewrite (moving from Ambarella to a TI chip). I wanted comprehensive integration tests to ensure we are matching the SOW of our contract.

I wrote high-level Cucumber features describing camera behavior from the perspective of our backend system. No implementation details - just what the camera should do when it wakes up, connects to LTE, captures images, etc.

Here's one example scenario. Notice how it describes behavior at a high level - no mention of specific APIs, data structures, or implementation details:

```gherkin
Feature: Online Status Report
  As an agent,
  I want to see a timestamped status report in the backend recording every time the camera came online
  So that I can analyze PIR trigger frequency and battery usage, as well as other visibility issues.

  Background:
    Given the camera is powered on
    And the camera has entered sleep mode

  # Acceptance Criteria

  Scenario: Camera wakes from RTC trigger timeout
    When the camera wakes from an RTC trigger timeout
    And the LTE connection is established
    Then an online status message is posted to the backend
    And the camera returns to sleep
    And no other HTTP messages are sent before going back to sleep
```

That last assertion - "no other HTTP messages are sent" - is important for battery life. If the camera makes extra API calls during wakeup, it drains the battery faster. This is the kind of requirement that's easy to verify in a test but easy to miss in code review.

From that scenario, Claude generated these step definitions in Rust:
```rs

#[when("the camera wakes from an RTC trigger timeout")]
async fn camera_wakes_rtc(world: &mut TestWorld) {
    world.camera_in_sleep_mode = false;
    utils::trigger_rtc_event(&world.http_client)
        .await
        .expect("Failed to trigger RTC event");
}

#[when("the LTE connection is established")]
async fn lte_connection_established(world: &mut TestWorld) {
    utils::set_lte_online(&world.http_client)
        .await
        .expect("Failed to set LTE online");
    world.lte_connected = true;
    // Wait for connection to stabilize
    tokio::time::sleep(Duration::from_millis(500)).await;
}

#[then("the camera returns to sleep")]
async fn camera_returns_to_sleep(world: &mut TestWorld) {
    // Wait for wakelocks to be released (indicating sleep)
    let result = wakelock::wait_until_can_sleep(Duration::from_secs(10)).await;
    assert!(
        result.is_ok(),
        "Camera did not return to sleep: {:?}",
        result
    );
    world.camera_in_sleep_mode = true;
}

// ... snipped other assertions
```

I let Claude run for about 8 hours implementing all 6 features and 16 scenarios. Some of these were genuinely complex - one scenario required implementing a full WebRTC peer connection to verify that the camera could connect a data channel to a remote viewer. Claude actually asked me if I was sure I wanted it to implement that much infrastructure just for a test. I said yes (perks of having a Claude Code max plan).

In the end I got a comprehensive integration test suite that verifies all major firmware behaviors, with requirements documented in a format that's both human-readable and machine-verifiable. When we inevitably refactor parts of the firmware, these scenarios will catch regressions immediately.

More importantly, when a new engineer joins the team, they can read the feature files and understand what the camera is supposed to do without reading thousands of lines of embedded Rust code.

# Where This Leaves Us

I think spec-driven development with tools like Cucumber is going to become standard practice for AI-assisted development. The workflow matches how LLMs actually work: bounded tasks, clear success criteria, and context re-injection at the right moments.

**What this doesn't solve:** This isn't a replacement for software engineering expertise. Someone still needs to design the system architecture, choose the right data structures, and make decisions about how components interact. Writing good Cucumber scenarios requires understanding what behavior matters and how to test it meaningfully.

In my experience, this approach lets AI agents handle senior engineer-level implementation work, but you still need principal or staff-level thinking for architecture and design. The difference is that the principal engineer can focus on those high-level decisions instead of implementing every detail.

**What I'm still figuring out:** AI agents have a tendency to give up when things get hard. Claude will sometimes leave `TODO:` comments in the code or declare victory before all scenarios actually pass. I'm currently experimenting with:
- Better prompting techniques to keep agents iterating longer
- Automated verification that step definitions actually implement the steps (not just stubs)
- Ways to detect when an agent has given up and needs a nudge

I'd love to hear from others experimenting with similar approaches. What's worked for you? What patterns have you found for keeping AI agents on track during long-running sessions?
