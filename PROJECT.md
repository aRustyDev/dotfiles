# Dotfiles Evolution Project

## 🎯 GitHub Project

**Project URL:** https://github.com/users/aRustyDev/projects/16
**Repository Issues:** https://github.com/aRustyDev/dotfiles/issues

**Project Title:** Dotfiles Evolution: Nix-Darwin Excellence

**Project ID:** PVT_kwHOAiotK84A85FP

## 📋 Project Setup

The GitHub Project has been created with the following configuration:

### Columns (Status Field)
- **Todo** - New issues start here
- **In Progress** - Active work
- **Done** - Completed items

### Fields Available
- **Title** - Issue/PR title
- **Assignees** - Who's working on it
- **Status** - Todo/In Progress/Done
- **Labels** - Issue labels
- **Priority** - High/Medium/Low
- **Milestone** - Associated milestone
- **Repository** - Source repository
- **Linked PRs** - Related pull requests

## 🚀 Next Steps

1. **Create Issues**
   ```bash
   ./scripts/create-github-issues.sh
   ```

2. **Link Issues to Project**
   After creating issues, they can be added to the project using:
   ```bash
   gh project item-add 16 --owner @me --url [issue-url]
   ```

3. **View Project**
   Visit: https://github.com/users/aRustyDev/projects/16

## 📊 Milestones Overview

1. **Configuration Review** - Review all existing modules (Due: Jan 16)
2. **mkOutOfStoreSymlink Implementation** - Implement symlinks (Due: Jan 23)
3. **Hybrid Approach Analysis** - Evaluate hybrid configs (Due: Jan 30)
4. **Documentation Suite** - Create comprehensive docs (Due: Feb 13)
5. **Testing Framework** - Implement testing (Due: Feb 27)
6. **Special Integrations** - Claude, 1Password, VPN (Due: Mar 6)

## 📝 Issue Distribution

- Configuration Reviews: 29 issues
- Special Features: 3 issues
- Infrastructure: 10 issues
- Documentation: 8 issues
- Testing: 5 issues
- **Total: 55 issues**

## 🔧 Management Commands

### Add all issues from a milestone to project
```bash
# Example for milestone 1
gh issue list --milestone 1 --limit 100 --json url --jq '.[].url' | \
while read url; do
  gh project item-add 16 --owner @me --url "$url"
done
```

### Update issue status in project
```bash
gh project item-edit --project-id PVT_kwHOAiotK84A85FP --id [item-id] --field-id PVTSSF_lAHOAiotK84A85FPzgwwa4s --single-select-option-id 47fc9ee4  # In Progress
```

### View project items
```bash
gh project item-list 16 --owner @me --limit 100
```
