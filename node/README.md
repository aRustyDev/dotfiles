# Node

> Everything should use [PNPM][pnpm-io] (For Package Management) and [Volta][volta-sh] (For Node Version Management)

- [Volta Setup][volta]
  - `brew install volta`
  - `volta install node` (VPN Must be off)
  - `export VOLTA_HOME=${XDG_CONFIG_HOME:-$HOME/.config}/volta`
  - `export PATH=$PATH:$VOLTA_HOME/bin`
  - `export VOLTA_FEATURE_PNPM=1`
- [PNPM][pnpm]
  - `volta install pnpm`
- [megalinter][megalinter]
  - `volta install mega-linter-runner`
  - `pnpm exec|run mega-linter-runner --flavor salesforce -e "'ENABLE=DOCKERFILE,MARKDOWN,YAML'" -e 'SHOW_ELAPSED_TIME=true'`
- [Claude Code][claude-code]
  - `volta install anthropic-ai/claude-code`
- [OpenAI Codex][codex]
  - `volta install openai/codex`
- [Gemini CLI][gemini]
  - `volta install google/gemini-cli`

- [megalinter]: https://megalinter.io/latest/install-locally/ "Megalinter Install"
- [pnpm-io]: https://pnpm.io/ "PNPM"
- [volta-sh]: https://volta.sh/ "Volta"
- [claude-code]: https://docs.anthropic.com/en/docs/claude-code/setup "Claude"
- [codex]: https://github.com/openai/codex "OpenAI"
- [gemini]: https://github.com/google/gemini-cli "Gemini"
- [volta]: https://docs.volta.sh/advanced/installers "Installers"
- [pnpm]: https://docs.volta.sh/advanced/pnpm "Volta + PNPM"
