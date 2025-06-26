
# Tool Preferences
- Use `orb` over `docker` on macos
- use `rg` over `grep` when possible

PLAN_MODEL

# General Priorities

- focus on identifying what still needs improvement rather than declaring premature success.
- when making code recommendations follow the CODING_PRIORITIES
- Before exploring, attempt to predict how complex of a topic you are going to explore, if the topic is very large, complex or if you are unsure prompt me for permission to use a more powerful model. In every other case use the current "every-day" model to conduct your exploration.

# Relevant Context Files

- TODO: tasks or features that need to be completed in the future, this is used to persist tasks for later completion. Non-Append edits to this file MUST be authorized by me EVERY TIME.
- BUGS: this holds detailed descriptions of bugs that are identified in the code base, and is used to help generate changelogs and issues, and enables putting off fixing bugs that would cause large changes in the code until the current feature or fix is implemented. This is a APPEND ONLY file
- HOW2: This file holds contextual hints on how I want you to complete certain tasks. This is a READ ONLY file
- PHRASES: This file holds context for what I mean when I use short hand phrases. For example if I say "Make your case" this file details the process I want you to follow to "Make Your Case". This is a READ ONLY file
- TOOLS: This files holds tool preferences and patterns for different use cases.
- TDD: This file contains the Test driven development pattern you should follow. This is a READ ONLY file
- PATHS: this file contains paths that are either sensitive and should NEVER be editted with out explicit and confirmed approval, and require additional review before doing so. It also contains files that are "free-range" and can be editted freely so long as you follow the accompanying rules. This is a READ ONLY file
- CHANGELOG: this file is used by you to hold the statement of work that was asked for and what was objectively completed. This is an append only file.
- ANALYSIS: this file should contain all of your analyses 

# Test Driven Development

1. When starting a new session, explore the code and update the CLAUDE.md file with your assessment.
2. Prompt to see what model to use for Planning, default to whatever PLAN_MODEL value is in local CLAUDE.md
3. Prompt to see what model to use for Coding, default to whatever CODE_MODEL value is in local CLAUDE.md
4. When starting your development cycle
  1. Clean your workspace, by checking for duplicate files, functions, methods, variables, or other items, then deconstructing the duplicate file by verifying that removing quantized units of code in the file will not break things.
  2. Conduct targeted tests as you go and continue trimming code until you no longer have duplicate code.
  3. If you find other errors while you are working on deduplication, then make a note in the CLAUDE.md file, patch out the problem and continue deduplicating.
  4. When deduplication is complete, begin looking for code that calls code that doesn't exist, when you find it, determine if the caller or the callee is the problem by determining if the targt code is missing or not needed.
  5. For example if a test was copy and pasted as reference, and therefore the code it calls likely doesn't exist, the caller is the problem.
  6. But if a function was renamed and test is calling the old name then the caller could be the problem. Default to the tests being the problem and conform tests to fit the code not code to fit the tests.
  7. Plan and update CLAUDE.md
  8. Prompt, Present, and Clarify
  9. Code and Test
     1. Branch and checkout
     2. Smallest changes possible
     3. Then create tests to maintain 100% coverage; capture all errors and issues, then update GIT Origin / Issue tracker
     4. When tests are passing creat commit (w/ pre-commit); update issue tracker w/ resolution
     5. Repeat until Goal is complete
  10. Generate work report, changelog, and JIRA Template
  11. Create Tag
  12. create PR/Merge back
     
     
