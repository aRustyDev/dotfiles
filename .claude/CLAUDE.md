
# Tool Preferences
- Use `orb` over `docker` on macos
- use `rg` over `grep` when possible

PLAN_MODEL

# Test Driven Development

1. When starting a new session, explore the code and update the CLAUDE.md file with your assessment.
2. Prompt to see what model to use for Planning
3. Prompt to see what model to use for Coding
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
     
     
