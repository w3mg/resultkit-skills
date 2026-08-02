# BDD Spec — Gold-Standard Examples

Incorporated from `BDD SPEC EXAMPLES.md`. These are adaptable SaaS BDD scenarios — copy the closest
one to the behavior you are speccing and change the specifics. They all describe user-visible
behavior and avoid implementation detail.

---

## 1) User invites a teammate

**Feature:** Invite a teammate to the workspace

**Scenario: Admin sends an invite**

- Given I am signed in as a workspace admin
- And my workspace has at least one available seat
- When I enter a teammate's email address
- And I click Send invite
- Then the teammate receives an invitation email
- And the teammate appears in the Pending Invites list
- And the available seat count decreases by one

## 2) Trial user upgrades to paid plan

**Feature:** Upgrade from trial to paid subscription

**Scenario: Trial user upgrades successfully**

- Given I am signed in on a trial account
- And my trial has not expired
- When I choose the Pro plan
- And I enter valid payment details
- And I confirm the purchase
- Then my account switches to the Pro plan
- And billing starts immediately
- And I can access Pro-only features

## 3) User resets password

**Feature:** Password reset

**Scenario: User requests a reset link**

- Given I am on the sign-in page
- When I click Forgot password
- And I enter my account email address
- Then I see a confirmation message
- And a password reset email is sent to that address

**Scenario: User resets password with a valid token**

- Given I opened a password reset link from my email
- When I enter a new password that meets the requirements
- And I confirm the new password
- Then my password is updated
- And I can sign in with the new password

## 4) Customer creates a new project

**Feature:** Create a project

**Scenario: User creates a project successfully**

- Given I am signed in
- And I have permission to create projects
- When I enter a project name
- And I click Create project
- Then the project is created
- And I am taken to the project overview page
- And the project appears in my project list

## 5) Admin changes a billing plan

**Feature:** Manage subscription plan

**Scenario: Admin downgrades a plan**

- Given I am signed in as an account admin
- And my workspace is on the Pro plan
- When I select the Basic plan
- And I confirm the change
- Then my plan updates to Basic
- And I see the date when the change takes effect
- And features not included in Basic are marked unavailable

## 6) Team member loses access after removal

**Feature:** Remove a user from the workspace

**Scenario: Admin removes a teammate**

- Given I am signed in as a workspace admin
- And the workspace contains a teammate with access
- When I remove that teammate from the workspace
- Then the teammate no longer appears in the member list
- And the teammate can no longer access the workspace
- And an audit record is created for the removal

## 7) User adds an integration

**Feature:** Connect a third-party integration

**Scenario: User connects Slack successfully**

- Given I am signed in
- And I have permission to manage integrations
- When I choose Slack from the integrations page
- And I approve the connection
- Then Slack is connected to my workspace
- And the integration appears as active
- And I can configure notification settings

## 8) Usage limit is reached

**Feature:** Enforce plan limits

**Scenario: User cannot add more seats than the plan allows**

- Given my workspace plan includes 10 seats
- And all 10 seats are already in use
- When I try to invite another teammate
- Then I see a message that the seat limit has been reached
- And the invite is not sent
- And I am offered an upgrade path

---

## What makes these solid

- They focus on **user-visible behavior**.
- They use concrete starting conditions, actions, and outcomes.
- They avoid implementation details like database writes or service calls.
- They map cleanly to product requirements, QA checks, and automation.

## SaaS BDD pattern to copy

A strong SaaS scenario usually follows this structure:

- Given a user role, account state, or plan state.
- When the user performs one action.
- Then the system shows one clear result.

Example:

- Given I am an admin on a paid workspace.
- When I invite a teammate.
- Then the invite is sent and the seat count updates.
