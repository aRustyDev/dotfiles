# Node
> Everything should use [PNPM][2] (For Package Management) and [Volta][3] (For Node Version Management)

- [megalinter][1]
  - `volta install mega-linter-runner`
  - `pnpm exec|run mega-linter-runner --flavor salesforce -e "'ENABLE=DOCKERFILE,MARKDOWN,YAML'" -e 'SHOW_ELAPSED_TIME=true'`
- [Claude Code][4]
  - `volta install anthropic-ai/claude-code`
- [OpenAI Codex][5]
  - `volta install openai/codex`
- [Gemini CLI][6]
  - `volta install google/gemini-cli`

- [1]: https://megalinter.io/latest/install-locally/ "Megalinter Install"
- [2]: https://pnpm.io/ "PNPM"
- [3]: https://volta.sh/ "Volta"
- [4]: https://docs.anthropic.com/en/docs/claude-code/setup "Claude"
- [5]: https://github.com/openai/codex "OpenAI"
- [6]: https://github.com/google/gemini-cli "Gemini"
