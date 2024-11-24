+++
Categories = ["Development"]
title = "Implementing Licensing & Permissions in a React Redux app"
Tags = ["Development", "VoirDire App"]
date = "2024-10-20T10:00:00-05:00"
image = "/images/projects/voir-dire-license-modal.png"
quote = "By solving the problem at the right layer, we were able to implement licensing in 1/4 of the budgeted time, bringing the project back on track."
+++

In the process of building out the [VoirDire App](https://www.voirdire.app/) for our client, we ran into an interesting
problem.  How do we enforce licensing requirements in a cross-cutting way, without tediously identifying every area
in the UI where the user might take an action that they were not allowed to take?  The client's licensing requirements
were:

* On the free plan, a user can have 1 trial, up to 20 jurors, and up to 20 stored questions.
* With a standard license ($30), up to trials, 100 jurors, and 100 stored questions.
* An unlimited license ($50) removes all limitations.

Since we are using Redux to handle application state, calculating the remaining jurors, trials, etc. in the license can
be done with a selector.  The selector accepts the entire redux state and the user's current license key, then calculates
whether they are over or under the limit.

Fortunately we were also using some pretty straightforward redux actions.  It made it easy to build a Redux middleware
to intercept actions such as `createTrial`, check if the user was already over the limit, and if so dispatch a different
action.  We created a new Redux slice called `licensing` which had a property called `licensingError`.  Then in the
layout, we have a component that watches for licensing errors using `useSelector(selectLicensingError)`.  If an error
is present, it pops up the licensing modal blurring out the entire screen.  When the modal is dismissed, it dispatches
an action to clear the error.

This architecture allowed us to enforce the licensing requirement on every button on the site, without having to build
licensing checks on every individual button!  By applying my experience with Redux and solving the problem at the right
layer, we were able to implement licensing in 1/4 of the time that was budgeted, bringing the project back on track
for completion within budget.
