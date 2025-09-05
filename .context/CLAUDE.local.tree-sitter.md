# Claude Project Management Guide

This guide explains how to use the `.claude/` directory structure for managing development projects.

**Starting Point**: Always check [.claude/INDEX.md](.claude/INDEX.md) first to see all available projects and navigate the structure.

## Directory Structure Pattern

Each project follows this standard structure:
```
.claude/
├── INDEX.md                      # Main index listing all projects
├── CLAUDE.md                     # This file - usage guide
├── cache/                        # Temporary cache files (git-ignored)
│   └── {project}/                # Project-specific cache files
├── plans/{category}/{project}/
│   ├── INDEX.md                  # Plans and strategies (roadmap, milestones, etc.)
│   └── TODO.md                   # Project task tracking (labeled as "todos" in INDEX)
├── notes/{category}/{project}/
│   └── INDEX.md                  # Notes and scratch files (brainstorming, ideas, etc.)
├── tests/{category}/{project}/
│   └── INDEX.md                  # Test plans, cases, results, and automation
├── build/{category}/{project}/
│   └── INDEX.md                  # Build scripts and tools (justfile, makefile, etc.)
├── docs/{category}/{project}/
│   ├── INDEX.md                  # Historical documentation (analysis reports, etc.)
│   └── adr/                      # Architecture Decision Records
│       └── *.md                  # Individual ADR documents
├── examples/{category}/{project}/
│   └── INDEX.md                  # Code snippets and sample configurations
├── feedback/{category}/{project}/
│   └── INDEX.md                  # User interaction forms, Q&A docs, code reviews
└── help/{category}/{project}/
    └── INDEX.md                  # FAQs and troubleshooting guides
```

## INDEX.md Files

### Purpose
INDEX.md files serve as the entry point and navigation guide for each directory in the .claude structure. They should:
- Provide an overview of the directory's contents
- Link to important files and subdirectories
- Explain the organization and purpose of the content
- Include quick reference information

### What Goes in INDEX.md Files

1. **Directory Overview** - Brief description of what this directory contains
2. **Table of Contents** - Links to key files and subdirectories
3. **Quick Links** - Direct paths to frequently accessed files
4. **Organization Notes** - How content is structured and why
5. **Cross-references** - Links to related directories or documentation
6. **Status Information** - Current state of projects or documentation

### INDEX.md Best Practices

- **Keep it concise** - INDEX files are for navigation, not detailed documentation
- **Update regularly** - Add new files and remove obsolete references
- **Use relative links** - Link to files within the .claude structure
- **Include descriptions** - Don't just list files, explain what they contain
- **Organize logically** - Group related items together

### Example INDEX.md Structure
```markdown
# [Directory Name] Index

Brief description of this directory's purpose.

## Overview
What this directory contains and why it exists.

## Contents

### [Category 1]
- [File/Directory Name](./path) - Brief description
- [Another File](./path) - What it contains

### [Category 2]
- [Important Document](./path) - Why it's important

## Quick Links
- [Most Used File](./path)
- [Related Directory](../other/path)

## Status
Current state of the content in this directory.

## Lessons Learned
Key insights discovered:
- **[Topic]**: Brief description - [Details](./path-to-details)
- List important discoveries here

## Recent Feedback
- **[Date]**: [Type] - [Status] - [Link](./.claude/feedback/YYYY-MM-DD-type.md)
- Track pending feedback items here
```

## Creating a New Project

To create a new project structure, follow these steps:

1. **Choose a category and project name**
   - Category examples: `tree-sitter`, `languages`, `package-managers`
   - Project examples: `kvconf`, `rustc`, `cargo`

2. **Create the directory structure**
   ```bash
   PROJECT_CAT="category-name"
   PROJECT_NAME="project-name"

   mkdir -p .claude/plans/$PROJECT_CAT/$PROJECT_NAME
   mkdir -p .claude/notes/$PROJECT_CAT/$PROJECT_NAME
   mkdir -p .claude/tests/$PROJECT_CAT/$PROJECT_NAME
   mkdir -p .claude/build/$PROJECT_CAT/$PROJECT_NAME
   mkdir -p .claude/docs/$PROJECT_CAT/$PROJECT_NAME
   mkdir -p .claude/examples/$PROJECT_CAT/$PROJECT_NAME
   mkdir -p .claude/feedback/$PROJECT_CAT/$PROJECT_NAME
   mkdir -p .claude/help/$PROJECT_CAT/$PROJECT_NAME
   ```

3. **Create required files**
   - `plans/$PROJECT_CAT/$PROJECT_NAME/TODO.md` - Task tracking
   - `plans/$PROJECT_CAT/$PROJECT_NAME/INDEX.md` - Overview of development phases
   - `notes/$PROJECT_CAT/$PROJECT_NAME/INDEX.md` - Notes and observations
   - `tests/$PROJECT_CAT/$PROJECT_NAME/INDEX.md` - Test documentation
   - `build/$PROJECT_CAT/$PROJECT_NAME/INDEX.md` - Build automation documentation
   - `docs/$PROJECT_CAT/$PROJECT_NAME/INDEX.md` - Historical documentation
   - `examples/$PROJECT_CAT/$PROJECT_NAME/INDEX.md` - Code examples and samples
   - `feedback/$PROJECT_CAT/$PROJECT_NAME/INDEX.md` - Feedback and review docs
   - `help/$PROJECT_CAT/$PROJECT_NAME/INDEX.md` - Help and resources

4. **Update the main INDEX.md**
   Add your project to `.claude/INDEX.md` following the existing pattern

## Managing TODOs

### TODO.md Format

Each project's TODO.md (located in `plans/{category}/{project}/TODO.md`) should follow this structure:
```markdown
# Project Name TODO List

## Current Phase: [Phase Name]

### Phase 1: [Name]
- [ ] Task description
- [x] Completed task - commit: abc123, tag: v1.0.0
- [x] Another completed task - PR: #42, commit: def456

### Completed TODOs
- [x] Task name - commit: abc123, date: 2024-01-15
```

### Workflow for TODOs

1. **When starting a task**: Mark it as in progress
   ```markdown
   - [ ] ➡️ Implement feature X
   ```

2. **When completing a task**: Mark complete with reference
   ```markdown
   - [x] Implement feature X - commit: abc123
   ```

3. **Include relevant references**:
   - Commit hash: `commit: abc123`
   - Git tag: `tag: checkpoint-1.0`
   - Pull request: `PR: #42`
   - Date completed: `date: 2024-01-15`

4. **Move to completed section** when phase is done

### Example TODO Entry
```markdown
- [x] Add validation script to ensure all test files are valid - commit: 5f4e3d2, tag: checkpoint-1.0
```

## Best Practices

### 1. Plan Organization
- Keep phases in separate files for large projects (see [Plans Directory](#plans-directory))
- Use numbered prefixes for ordering (00-overview.md, 01-phase1.md)
- Include checkpoint requirements at phase ends
- **MANDATORY**: All checkpoints REQUIRE external review before proceeding
- Each plan document must have a Table of Contents at the top
- Follow plan lifecycle: Draft → Review → Active → Completed

### 2. Notes Management
- Document key learnings as you discover them (see [Notes Directory](#notes-directory))
- Record design decisions with rationale
- Link to relevant commits or issues
- Transfer significant lessons to formal documentation
- Use notes for quick capture, promote to docs when valuable

### 3. Test Documentation
- Document test patterns and examples
- Include commands for running tests
- Track performance benchmarks

### 4. Build Documentation
- Document build scripts and automation
- Follow the [Justfile Modularization Strategy](.claude/build/README.md)
- Include justfile/makefile documentation
- Track build performance and optimizations
- **IMPORTANT**: Read `.claude/build/README.md` when creating new projects

### 5. Documentation Management
- Store ADRs (Architecture Decision Records)
- Archive analysis and troubleshooting reports
- Keep design documents and specifications

### 6. Examples Collection
- Add code snippets demonstrating usage
- Include sample configuration files
- Provide working examples for common patterns

### 7. Feedback Management
- Store user interaction forms and templates
- Document Q&A sessions with reviewers
- Archive code review feedback
- Track feature requests and user suggestions
- Record design review outcomes

### 8. Help Resources
- Add troubleshooting guides for common issues
- Include useful commands and patterns
- Link to external documentation

### 9. Commit Integration
When completing todos:
```bash
# Make your changes
git add -A
git commit -m "feat: implement feature X"

# Get the commit hash
COMMIT_HASH=$(git rev-parse HEAD)

# Update TODO.md with the hash
# - [x] Implement feature X - commit: $COMMIT_HASH

# For significant milestones, create a tag
git tag -a checkpoint-1.0 -m "Completed Phase 1"
```

## Project Lifecycle

1. **Planning**: Create structure, write plans in phases (use [Plans Directory](#plans-directory))
2. **Development**: Work through TODOs, capture discoveries in [Notes](#notes-directory)
3. **Documentation**: Promote valuable notes to formal docs
4. **Testing**: Document test strategies and results (see [Tests Directory](#tests-directory))
5. **Completion**: Archive completed plans, extract lessons learned

## Integration with Development Workflow

1. **Before starting work**: Review current TODOs and active plans
2. **During development**: Capture discoveries in notes immediately
3. **After completing tasks**: Update TODO with commit refs
4. **At checkpoints**: Review all documentation is current
5. **Project completion**: Archive plans, promote notes to docs

## Project Upkeep and Maintenance

### Ongoing Documentation Tasks

1. **When adding new files**:
   - Add reference to relevant INDEX.md
   - Update Quick Links if frequently accessed
   - Add to appropriate category section

2. **When completing features**:
   - Update TODO.md with completion status
   - Add links to INDEX.md for new documentation
   - Update status sections in relevant INDEX files

3. **When discovering solutions**:
   - Add to help/ directory if reusable
   - Update INDEX.md with new help guides
   - Cross-reference in related documentation
   - Document lesson learned if significant

4. **When learning important lessons**:
   - Quick capture in notes/ directory
   - Add to formal lessons-learned.md if significant
   - Update Lessons Learned section in relevant INDEX.md files
   - Include context, problem, and solution

5. **When receiving feedback**:
   - Create dated feedback file immediately
   - Use feedback template for consistency
   - Add to project TODOs if actionable
   - Update feedback section in INDEX.md

6. **Weekly/Regular maintenance**:
   - Review INDEX.md files for accuracy
   - Remove dead links
   - Add missing file references
   - Update status information
   - Check for pending feedback items
   - Archive old resolved feedback

### INDEX.md Update Checklist

When working on a project, update INDEX.md files when you:
- [ ] Create new documentation files
- [ ] Add test files or test results
- [ ] Complete a development phase
- [ ] Discover important patterns or solutions
- [ ] Find frequently-accessed files
- [ ] Change directory organization
- [ ] Archive or deprecate content
- [ ] Learn significant lessons worth sharing
- [ ] Identify anti-patterns to avoid
- [ ] Receive new feedback requiring action
- [ ] Complete feedback-driven changes
- [ ] Promote notes to formal documentation
- [ ] Create or complete plans

### Quick Update Commands

```bash
# Find all INDEX.md files in project
find .claude -name "INDEX.md" -type f

# Check for broken links in INDEX files
# (manual review recommended)
grep -h "\[.*\](" .claude/**/INDEX.md | sort | uniq
```

## Cache Directory Usage

### Purpose
The `.claude/cache/` directory is for temporary files that should not be tracked in version control.

### When to Use Cache
- **Downloaded repositories**: When cloning repos for testing or analysis
- **Temporary test files**: Large test datasets downloaded from external sources
- **Build artifacts**: Temporary compiled files during testing
- **External resources**: Downloaded documentation, example files, or datasets

### Usage Guidelines
1. **Create project-specific subdirectories**:
   ```bash
   mkdir -p .claude/cache/tree-sitter-kvconf/
   ```

2. **Example workflow**:
   ```bash
   # Downloading a repo for testing
   cd .claude/cache/
   git clone https://github.com/example/large-repo.git

   # Extract only needed files to actual project
   cp large-repo/.npmrc ../../../tree-sitter-dotenv/test/fixtures/

   # Cache remains but doesn't clutter project
   ```

3. **Ensure .gitignore includes**:
   ```
   .claude/cache/
   ```

### What NOT to Cache
- Project source code
- Important documentation
- Test results that need to be preserved
- Anything that should be in version control

## Lessons Learned Documentation

### Purpose
Lessons learned capture valuable insights, mistakes to avoid, and best practices discovered during development. They help future developers (including AI agents) avoid repeating mistakes and leverage proven solutions.

### Where to Document Lessons

1. **During Development** - Quick captures in `notes/{category}/{project}/`
   - Use dated entries or topic-based files
   - Include context about what you were trying to accomplish
   - Note what worked and what didn't

2. **Formal Documentation** - Consolidated lessons in `docs/{category}/{project}/lessons-learned.md`
   - Transfer significant insights from notes
   - Organize by topic or chronologically
   - Include specific examples and solutions

3. **INDEX.md Files** - Summary in "Lessons Learned" section
   - List key insights with links to detailed documentation
   - Keep updated as new lessons are discovered
   - Include both positive patterns and anti-patterns

### What Constitutes a Lesson Learned

Document insights about:
- **Technical Discoveries**: "token.immediate prevents parser state bugs"
- **Tool Quirks**: "Zed caches extension files even after uninstall"
- **Performance Findings**: "Large regex patterns slow down parsing"
- **Integration Issues**: "File paths must be absolute in tree-sitter"
- **Best Practices**: "Always test with real-world config files"
- **Debugging Techniques**: "Use syntax tree view to diagnose highlighting"

### Lessons Learned Template

```markdown
# Lessons Learned - [Project Name]

## Overview
Brief summary of major insights from this project.

## Technical Lessons

### [Lesson Title]
**Context**: What we were trying to do
**Discovery**: What we learned
**Solution**: How to apply this knowledge
**Example**: Code or command that demonstrates this
**References**: Links to relevant commits, issues, or docs

## Tool-Specific Lessons

### [Tool Name]
- Quirk or behavior discovered
- Workaround or best practice
- Version this applies to

## Anti-Patterns to Avoid

### [What Not to Do]
**Why it's problematic**: Explanation
**Better approach**: Alternative solution
**Example**: Show the right way

## Performance Insights

### [Performance Topic]
- Measurement or observation
- Impact on the system
- Optimization approach
```

### INDEX.md Integration

Add this section to INDEX.md files:
```markdown
## Lessons Learned
Key insights from this project:
- **[Topic]**: Brief description - [Details](./.claude/lessons-learned.md#topic)
- **Performance**: Parser optimization findings - [Details](./.claude/docs/lessons-learned.md#performance)
- **Tool Quirks**: Zed extension caching issues - [Details](./.claude/docs/lessons-learned.md#zed-caching)
```

## Feedback Documentation

### Purpose
The feedback directory captures all external input about the project including code reviews, user suggestions, design discussions, and checkpoint reviews. This ensures that important feedback is preserved and acted upon.

### What Goes in the Feedback Directory

1. **Code Review Feedback**
   - Review comments from PRs or commits
   - Suggestions for improvements
   - Identified issues or concerns
   - Approval conditions

2. **Checkpoint Reviews**
   - External reviewer comments
   - Required changes before proceeding
   - Approval documentation
   - Follow-up action items

3. **User Interaction Sessions**
   - Q&A sessions with users or stakeholders
   - Feature requests and suggestions
   - Bug reports from users
   - Usability feedback

4. **Design Reviews**
   - Architecture discussions
   - API design feedback
   - Performance considerations
   - Security reviews

### Feedback File Naming Convention
```
YYYY-MM-DD-{type}-{topic}.md
```
Examples:
- `2024-01-15-checkpoint-phase2-review.md`
- `2024-01-16-code-review-parser-implementation.md`
- `2024-01-17-user-feedback-highlighting-issues.md`

### Feedback Documentation Template

```markdown
# Feedback: [Topic]

**Date**: YYYY-MM-DD
**Type**: [Checkpoint Review | Code Review | User Feedback | Design Review]
**Reviewer(s)**: [Name(s) or username(s)]
**Status**: [Pending | In Progress | Addressed | Deferred]

## Summary
Brief overview of the feedback session or review.

## Feedback Items

### 1. [Feedback Topic]
**Priority**: [High | Medium | Low]
**Feedback**: What was said or suggested
**Response**: How we plan to address this
**Status**: [Pending | Addressed | Won't Fix]
**Commit/PR**: [If addressed, link to commit or PR]

### 2. [Another Topic]
...

## Action Items
- [ ] Task resulting from feedback
- [ ] Another required action
- [x] Completed action - commit: abc123

## Follow-up Required
Any additional reviews or approvals needed.

## Notes
Additional context or discussion points.
```

### Workflow for Feedback

1. **Receiving Feedback**:
   - Create new file with date and descriptive name
   - Use the template to structure feedback
   - Set initial status to "Pending"

2. **Processing Feedback**:
   - Review all feedback items
   - Prioritize based on impact
   - Create TODOs for actionable items
   - Update status as work progresses

3. **Closing Feedback**:
   - Mark all items as addressed or won't fix
   - Document final outcomes
   - Update status to "Addressed"
   - Link to relevant commits/PRs

### Integration with Development Workflow

1. **Before Starting Work**:
   ```bash
   # Check for new feedback
   ls -la .claude/feedback/{category}/{project}/
   # Review any pending feedback files
   ```

2. **During Checkpoints**:
   - Create feedback file for checkpoint review
   - Document all reviewer comments
   - Block progress until feedback is addressed

3. **After Completing Features**:
   - Check if feature addresses any feedback
   - Update relevant feedback files
   - Link commits to feedback items

### Feedback Monitoring for AI Agents

The critical guideline "ALWAYS check project feedback files" means:

1. **Start of Session**:
   - List all feedback files in the project
   - Check for any with "Pending" or "In Progress" status
   - Review recent feedback (last 7 days)

2. **Before Major Changes**:
   - Ensure changes align with feedback
   - Check for relevant design reviews
   - Verify no blocking feedback exists

3. **Documentation**:
   - Update feedback files when addressing items
   - Link commits to feedback items
   - Change status when items are resolved

### Quick Commands

```bash
# Find all pending feedback
grep -r "Status: Pending" .claude/feedback/

# List recent feedback files (last 7 days)
find .claude/feedback -name "*.md" -mtime -7

# Check for high-priority feedback
grep -r "Priority: High" .claude/feedback/
```

## Notes Directory

### Purpose
The notes directory is your project's working memory - a place for capturing thoughts, ideas, observations, and discoveries as they happen. Unlike formal documentation, notes are informal, quick to write, and don't need to be polished.

### What Goes in Notes

1. **Development Observations**
   - Unexpected behaviors discovered
   - "Aha!" moments and insights
   - Questions that arise during development
   - Hypotheses to test later

2. **Design Sketches**
   - Quick architecture diagrams (as ASCII or descriptions)
   - API design ideas
   - Algorithm explanations
   - Alternative approaches considered

3. **Debug Sessions**
   - Steps taken to debug an issue
   - What worked and what didn't
   - Error messages and stack traces
   - Temporary workarounds

4. **Research Notes**
   - Findings from documentation reading
   - Relevant Stack Overflow answers
   - Useful code snippets found
   - Links to helpful resources

5. **Meeting/Discussion Notes**
   - Informal design discussions
   - Brainstorming sessions
   - Quick decisions made
   - Context for future reference

### Note File Organization

Use descriptive filenames that help you find notes later:
```
.claude/notes/{category}/{project}/
├── YYYY-MM-DD-topic.md          # Date-based for chronological notes
├── debugging-parser-bug.md      # Topic-based for specific issues
├── api-design-ideas.md          # Concept-based for ongoing thoughts
├── performance-observations.md  # Category-based for related notes
└── scratch.md                   # General scratchpad
```

### Note-Taking Workflow

1. **Quick Capture** - Write immediately when you discover something
2. **Raw Format** - Don't worry about formatting or completeness
3. **Include Context** - Note what you were doing when you discovered this
4. **Add Questions** - Document uncertainties for later investigation
5. **Link Freely** - Reference files, commits, issues, URLs

### Note Template (Optional)

```markdown
# [Topic/Date]

## Context
What I was working on when this came up.

## Observation/Idea
The thing I discovered or thought of.

## Questions
- What I still need to figure out
- Things to investigate

## Next Steps
- [ ] Actions to take
- [ ] Things to test

## References
- Links to relevant files/docs
```

### Converting Notes to Documentation

When notes prove valuable, promote them to formal documentation:
- **Technical insights** → Lessons Learned
- **Design decisions** → ADRs
- **How-to procedures** → Help guides
- **Bug investigations** → Analysis docs
- **API designs** → Technical specs

### Best Practices

1. **Write freely** - Notes are for you and future developers
2. **Date entries** - Helps understand evolution of thinking
3. **Be specific** - Include file paths, function names, line numbers
4. **Keep it messy** - Perfect is the enemy of captured
5. **Review periodically** - Extract valuable insights to formal docs

## Plans Directory

### Purpose
The plans directory contains structured development roadmaps, phase-based implementation plans, and strategic documents that guide project execution. Plans are more formal than notes but less permanent than documentation.

### What Goes in Plans

1. **Project Roadmaps**
   - Multi-phase development plans
   - Milestone definitions
   - Timeline estimates
   - Success criteria

2. **Implementation Plans**
   - Detailed technical approaches
   - Step-by-step procedures
   - Checkpoint requirements
   - Risk mitigation strategies

3. **TODO.md Files**
   - Current task lists
   - Completed task archives
   - Task priorities and assignments
   - Progress tracking

4. **Research Plans**
   - Investigation strategies
   - Experiment designs
   - Evaluation criteria
   - Resource requirements

### Plan Document Structure

Plans should be well-organized with clear sections:

```markdown
# [Plan Title]

## Table of Contents
- Link to all major sections

## Overview
Brief description of what this plan covers

## Goals
- Specific objectives
- Success criteria
- Non-goals (what's out of scope)

## Phases/Milestones
### Phase 1: [Name]
**Duration**: Estimated time
**Goals**: What will be accomplished
**Checkpoint**: Review requirements

#### Tasks
- [ ] Specific task with clear outcome
- [ ] Another task

### Phase 2: [Name]
...

## Timeline
Estimated schedule with buffer time

## Risks and Mitigation
Known challenges and how to address them

## Resources Required
Tools, access, dependencies needed

## Success Metrics
How we'll measure completion
```

### Plan Lifecycle

1. **Draft** → Initial ideas and rough structure
2. **Review** → Stakeholder feedback and refinement
3. **Active** → Currently being executed
4. **Completed** → Finished, archived with outcomes
5. **Superseded** → Replaced by newer plan

### Checkpoint Requirements

Plans often include mandatory checkpoints:
- **Define clear criteria** for proceeding
- **Document required approvals**
- **Block progress** until checkpoint passed
- **Create feedback documents** for reviews

### Integration with Development

1. **Before starting work**: Review active plans
2. **During development**: Update TODO.md progress
3. **At milestones**: Conduct checkpoint reviews
4. **After completion**: Document outcomes and lessons

### Plan File Naming

Use numbered prefixes for ordering:
```
.claude/plans/{category}/{project}/
├── 00-overview.md           # Project overview and goals
├── 01-phase1-foundation.md  # First phase plan
├── 02-phase2-features.md    # Second phase plan
├── TODO.md                  # Active task tracking
└── archive/                 # Completed or obsolete plans
```

## Tests Directory

### Purpose
The tests directory contains test documentation, strategies, and results - NOT the actual test code. It complements your code tests with planning, analysis, and reporting.

### What Goes in Tests
- **Test strategies** - Overall approach to testing
- **Test plans** - What needs to be tested and why
- **Test results** - Outcomes from test runs
- **Performance benchmarks** - Speed and resource usage data
- **Coverage reports** - What's tested and what's not
- **Test fixtures documentation** - Explanation of test data

### When to Use
- Planning test approaches before implementation
- Documenting why certain tests exist
- Recording performance baselines
- Tracking test coverage over time

For detailed test documentation guidelines, see category-specific READMEs.

## Examples Directory

### Purpose
The examples directory contains working code samples, configuration examples, and usage demonstrations that help users understand how to use your project.

### What Goes in Examples
- **Complete working examples** - Runnable code demonstrating features
- **Configuration samples** - Example config files with comments
- **Integration examples** - How to use with other tools
- **Common patterns** - Frequently needed code snippets
- **Before/after comparisons** - Showing transformations

### When to Use
- Demonstrating complex features
- Providing starter templates
- Showing best practices
- Illustrating common use cases

For example quality guidelines and organization, see category-specific READMEs.

## Architecture Decision Records (ADRs)

### When to Create ADRs
Create an ADR when:

1. **Making significant technical decisions**:
   - Choosing between multiple implementation approaches
   - Selecting frameworks, libraries, or tools
   - Defining system architecture patterns

2. **Solving complex problems**:
   - Non-obvious solutions that need explanation
   - Trade-offs that affect future development
   - Performance vs. maintainability decisions

3. **Breaking from conventions**:
   - Deviating from established patterns
   - Using unconventional approaches
   - Overriding default behaviors

4. **Impacting future development**:
   - Decisions that will affect other developers
   - Choices that constrain future options
   - API design decisions

### Creating ADR Files
**IMPORTANT**: Each ADR must be documented in its own file. Do not just list ADRs in INDEX.md files.

### ADR Location
Store ADRs in: `.claude/docs/{category}/{project}/adr/`

### ADR Naming Convention
- Format: `ADR-XXX-short-descriptive-name.md`
- Example: `ADR-001-use-token-immediate.md`
- Number sequentially within project

### ADR Template
Each ADR file should follow this structure:
```markdown
# ADR-XXX: Title

## Status
[Proposed | Accepted | Deprecated | Superseded]

## Context
What is the issue that we're seeing that is motivating this decision?

## Decision
What is the change that we're proposing and/or doing?

## Consequences
What becomes easier or more difficult to do because of this change?

### Positive
- Benefits of this approach

### Negative
- Drawbacks or risks

### Neutral
- Changes that are neither good nor bad

## References
- Links to related documents
- Related ADRs
- External resources
```

### Examples of ADR-Worthy Decisions
- "Why we used token.immediate for parser fix"
- "Why we chose precedence order for value types"
- "Why we deferred array support"
- "Why we separate URI and URL parsing"

## Justfile Usage

The `.claude/` project uses a modular justfile system for build automation.

### Quick Start

```bash
# From the contributing/ directory
cd .claude && just              # List available commands
cd .claude && just test         # Run tests for current project
cd .claude && just build        # Build current project

# Or set up an alias
alias cjust='cd .claude && just'
cjust test                      # Run tests for current project
```

### Setting Current Project

The system uses configurable defaults:

```bash
# Method 1: Edit .claude/justfile
# Change: CATEGORY := "tree-sitter"
# Change: PROJECT := "kvconf"

# Method 2: Environment variables
export CLAUDE_CATEGORY=tree-sitter
export CLAUDE_PROJECT=kvconf
cd .claude && just test

# Method 3: One-off override
cd .claude && CLAUDE_CATEGORY=languages CLAUDE_PROJECT=rust just test
```

### Running Project Commands

```bash
# Use current project (set by variables)
cd .claude && just clean
cd .claude && just dev
cd .claude && just test

# Run command for specific project
cd .claude && just run tree-sitter kvconf clean
cd .claude && just run languages rust build

# Quick alias for current project
cd .claude && just x test
```

### Project Justfile Location

Project-specific justfiles are located at:
```
.claude/build/{category}/{project}/justfile
```

### Adding Commands to a Project

1. Edit the project's justfile
2. Use relative paths from the justfile location
3. Follow naming conventions (see `.claude/build/README.md`)

### Common Commands

Most projects support these standard commands:
- `clean` - Remove build artifacts
- `install` - Install dependencies
- `build` - Build the project
- `test` - Run tests
- `dev` - Full development cycle

### Getting Help

```bash
cd .claude && just --list                           # List all available commands
cd .claude && just run CATEGORY PROJECT --list      # List project-specific commands
```

For detailed information about the justfile system, see [build/README.md](.claude/build/README.md).

## Critical Guidelines for AI Agents

### 0. Navigation Starting Point
- **ALWAYS** start by reading [.claude/INDEX.md](.claude/INDEX.md) to understand available projects
- Use INDEX.md files in each directory to navigate the structure
- Check project-specific INDEX files for quick links and current status

### 1. Quick Links Management
- Keep the "Quick Links" section in project INDEX files fresh
- Add relevant files as you work on them
- Include direct paths to important documents
- Update when new critical files are created

### 2. Checkpoint Requirements
- **MANDATORY**: All checkpoints in plans REQUIRE external review
- NEVER proceed past a checkpoint without explicit approval
- Each checkpoint must have clear success criteria
- Document review outcomes and any required changes

### 3. Anti-Sycophancy Controls
- Always provide honest assessments of code quality
- Point out potential issues even if not asked
- Suggest better approaches when appropriate
- Don't agree with suboptimal solutions to please the user

### 4. Clarification Requirements
- **ALWAYS** ask questions when requirements are ambiguous
- Never make assumptions about user intent
- Request specific examples when behavior is unclear
- Confirm understanding before implementing

### 5. Plan Approval Process
- **NEVER** implement a plan without explicit approval
- Present plans for review before starting work
- Wait for user confirmation on approach
- Document any plan modifications requested

### 6. Project Tree Utilization
- **ALWAYS** make heavy use of the .claude/ structure
- Update help docs when finding solutions to problems
- Keep detailed notes while working
- Periodically compile notes into relevant docs/examples
- Think of future developers/AI agents who will use these resources

### 7. Feedback Monitoring
- **ALWAYS** check project feedback files for updates (see [Feedback Documentation](#feedback-documentation))
- Review feedback before starting new work sessions
- Incorporate feedback into current approach
- Document how feedback was addressed
- Update feedback file status when items are resolved

---

## Current Project: tree-sitter/kvconf

### Top Priorities
1. The zed extension works and highlights syntax
2. The extension correctly highlights value types
3. The extension correctly highlights the KEY
4. The extension supports ANY KEY=VALUE style files

### Open Decisions
- [ ] Is it better to support more file types or focus on just `.env` files?
- [ ] Should things like `.npmrc` get their own extension?

### Development Principles
- **Test-Driven Development**: Write tests before implementing features
- **Behavior-Driven Development**: Define expected behaviors clearly
- **Incremental Progress**: Small, tested changes with frequent commits
- **Regular Checkpoints**: External review at major milestones
- **Comprehensive Documentation**: Document all decisions and implementations
