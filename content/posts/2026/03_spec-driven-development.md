+++
Categories = ["AI", "Development"]
title = "Pushing Claude Code Further with Spec Driven Development"
Tags = ["AI", "Development", "Albers Aerospace", "Claude Code"]
date = "2026-03-20T10:00:00-05:00"
draft = true
+++

# Intro

My current development process with AI involves a lot of human in the loop.  Thats a bottleneck.  How do I get less human and more long running AI?
Code review is another bottleneck.  Is there a way I can get a final product that's just as secure, just as well-tested, just as good - without having eyes on every line of code?  What needs to stand out from the noise?

This is an unsolved problem.  Lots of blogs will tell you to review your test cases, but how do you know which ones are important when the previous developer named them "test_001" and "test_bug_fix_2935"?  Other blogs will tell you to push your code review left, into the planning phase.  But this doesn't catch hallucinations injected by the LLM.

Let's take a step back and think about what LLMs are good at.  LLMs are good at recognizing patterns, greenfielding small sections of code, refactoring (given adequate guardrails), and summarizing.  Context Management is the art of getting the most out of LLMs.  What we need is a way to break requirements down into small, LLM-context-window friendly bites, automate the verification of those requirements, and then compose them into a coherent whole.

In this blog I'm going to attempt to synthesize a couple of disparate conversations into an idea and experiment, and present the results.

# Where does the rigor go?

[This report from ThoughtWorks](https://www.thoughtworks.com/content/dam/thoughtworks/documents/report/tw_future%20_of_software_development_retreat_%20key_takeaways.pdf) raises a number of important questions - I'll be addressing the first one today but thinking through a number of other ones for future posts.
Some of the problems they identified:
- Spec driven development needs new tool formats
- Traditional user stories are too vague
- TDD produces dramatically better results with AI coding agents

If you've been coding with an Agentic coding loop for a while then you're familiar with the above problems.  How do we push past that?

## A locked-up experience from a decade ago, and a recent conversation that turned the key

When I was a young, naiive mid-level software developer at GDSX (later Concur, then SAP), I came across [cucumber.io](https://cucumber.io/).  I thought, "This is amazing!  Finally I can get the businesspeople to write clear acceptance criteria, and I can just go implement it!"  I even attempted to print out a set of cucumber specs and show them to the CEO to describe how a particular mission-critical feature would work.  She did not care in the slightest that the user stories and acceptance criteria on that sheet of paper were machine-readable and verifiable.  After realizing that the sales and business types weren't going to do the job for me, I decided I didn't want the hassle of implementing Cucumber specs, preferring traditional BDD tools like RSpec because all the setup, act, assert for one spec is self-contained.

Much more recently, I was discussing requirements with our CTO at Albers Aerospace.  He said "If we wanted to recreate this web service from scratch, how would we even know what the whole requirements set is?"  That question struck me - the requirements set was built iteratively from countless Jira tickets and Claude Code prompts that have now been lost to the archives.  We couldn't re-create the requirements from scratch, much less validate which ones are still relevant.  The requirements ought to live inside the repo.

After that conversation, the promise of Cucumber came back to me.  We *can* document all the requirements in the repo at a high level, *and* we can automate verification of those requirements.
The reason I had abandoned Cucumber in the past was the pain of implementing the steps, and the hassle of tracing a scenario through a dozen different files.  But AI can handle that.  It doesn't even have to do a particularly good job of code reuse.  And it can iterate over the details a lot faster than I can, and for a lot longer.

Cucumber maps well to the Context Engineering required for long-running AI coding agents:
* Individual steps are one-line self-contained sentences defining a particular behavior that should be implemented in less than 100 lines of code
* The individual steps roll up into an executable, verifiable Scenario
* The Scenarios are defined in the same file as the User Story giving the "why" to the AI agent.

## Benefits

The AI agent can be told to never modify feature files, and churn forever until all scenarios pass.  If an agent ever decides to modify a feature file, that turns into a red flag in code review that needs to be reviewed by a senior engineer for validity.  If an agent is implementing a feature in one section of the code and causes a failure in a wholly disconnected scenario, the user story gives the agent immediate feedback as to whether the failing scenario is still relevant, and re-injects the "Why" back into the context at the appropriate time.  This is a massive multiplier over simple failing tests, because the AI agent will often decide to modify the failing test to just "make it pass" rather than re-evaluating their approach.

## Experimenting

I've got a couple of experiments running with this, and am finding good success so far.

In the first experiment, I had to copy and modify a subset of features from one Rails app and package them up into a separate Rails app.  I accomplished this with the following process:
1. Run `rails new` in a new directory
2. Instruct Claude to copy certain features from the other Rails app
3. While Claude was running, I created several Cucumber feature files describing the new behavior I wanted to add
4. After Claude had copied the subset of the original Rails app, I instructed Claude to install Cucumber and implement all scenarios defined in the feature files.
5. Claude ran to completion and all the new features not only worked, they also had test coverage.

In the second experiment, I used cucumber-rs to create integration tests for the Albers SC-410 Camera firmware.  Since we are about to release revision 2 of the camera hardware with a complete firmware rewrite, I wanted to ensure that all the behavior was well tested.  I wrote very high level feature specs describing the behavior I wanted to see.  

For instance, here is one scenario from one feature:

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

From that, Claude generated these step definitions:
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

I've had Claude running continually for about 8 hours in the background now to verify all 6 features and 16 scenarios.  Some of them are complex, requiring Claude to implement an entire WebRTC peer connection to validate.  Claude initially questioned whether it was worth it, but since I have a max plan I said hell yeah.  Now we have a full-featured integration test suite that has verified all major requirements of the software, *and* we have the requirements documented in both a human-readable and AI-verifiable format.

# Conclusion

I believe spec-driven development with Cucumber is the (near) future.  It enables software engineers to specify behavior at a higher level, and allows Claude to verify behavior in a way that keeps the "why" in the near context at all times.  It also provides documentation of the entire requirement set for a particular app.

Note that this does not remove the hard parts of software engineering.  The engineer must still define how this component fits into the larger whole of the system.  Additionally the software engineer ought to be intimately involved in designing the data structures.  With spec-driven development, you can promote Claude to the senior software engineer level but it still requires principal or staff level involvement in the system architecture and design.

Finally, it's important to verify at least once that Claude has actually implemented the steps.  Claude has a tendency to bail out and leave TODO: comments when things are too hard.  It also likes to stop and declare success before all the specs have passed.  I am now looking into ways to get Claude to keep iterating for longer without human involvement, until it can implement all the required specs.
