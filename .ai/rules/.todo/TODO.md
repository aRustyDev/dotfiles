# TODOs for AI Rules

1. Make rule selection tool for dynamic `.rules` loading based on project type.
   - ex: create different rules for different roles
   - ex: create project specific rules (e.g. how to search code in TF vs Go projects)
2. Rules for [`semantic-release`](https://github.com/semantic-release/semantic-release) usage.
3. Rules for `.editorconfig` generation, enforcement, review, suggestions, etc.
4. Rules for `.gitattributes` generation, enforcement, review, suggestions, etc.
5. Rules for `.gitignore` generation, enforcement, review, suggestions, etc.
6. Rules for `Justfile` generation, enforcement, review, suggestions, etc.
   - ex: when should the agent create a recipe for something?
7. Rules for `Dockerfile` generation, enforcement, review, suggestions, etc.
8. Prompts for Rule Review; Look for conflicts after generation.
9. Tool for `rule` token optimization (should be plain text vs MD)

## Adopt `.init.rules` pattern

- Included as part of new project scaffolding.
- If `git config --local project.id` is null, then follow `.init.rules`.

### Example `.init.rules` snippet

```markdown
- if `.meta.json:id` is present, then set `git config --local project.id` to that value.
  - else set it with `git config --local project.id "$(uuidgen)"` && write to `.meta.json:id`
```
