## User

How can I install https://github.com/sjswerdloff/pre-commit-mcp as an MCP server?

## Assistant

I'll help you install the pre-commit-mcp server. Let me first examine what it is and then provide installation instructions.

**Tool Call: Fetch https://github.com/sjswerdloff/pre\-commit\-mcp**
Status: Completed

Skip to content

## Navigation Menu

      Toggle navigation                                                                                                                Sign in                                         Appearance settings                                                                                                                  Search or jump to...

# Search code, repositories, users, issues, pull requests...

                                                           Search                                                                                                                                 Clear

                                                                                  Search syntax tips

# Provide feedback

We read every piece of feedback, and take your input very seriously. Include my email address so I can be contacted Cancel Submit feedback

# Saved searches

## Use saved searches to filter your results more quickly

                                                                                                          Name                                                                                    Query

            To see all available qualifiers, see our documentation.                                                                       Cancel              Create saved search                                                Sign in                                                         Sign up                                               Appearance settings                      Resetting focus                                                 You signed in with another tab or window. Reload to refresh your session.        You signed out in another tab or window. Reload to refresh your session.        You switched accounts on another tab or window. Reload to refresh your session.          Dismiss alert                                                                                                                                    sjswerdloff        /    **      pre-commit-mcp    **    Public
               -                     Notifications    You must be signed in to change notification settings

-                   Fork     1
-                                   Star          0



      An MCP server that allows your LLM to issue pre-commit in the repo you are working in and process the results                                                 0          stars                                1          fork                                Branches                                Tags                                Activity                                                        Star                                        Notifications    You must be signed in to change notification settings

# sjswerdloff/pre-commit-mcp

                           mainBranchesTagsGo to fileCodeOpen more actions menu

## Folders and files

| Name | Name | Last commit message | Last commit date |
| ---- | ---- | ------------------- | ---------------- |

|

## Latest commit

 

## History

5 Commits |
| pre_commit_mcp | pre_commit_mcp |   |   |
| tests | tests |   |   |
| .gitignore | .gitignore |   |   |
| .pre-commit-config.yaml | .pre-commit-config.yaml |   |   |
| README.md | README.md |   |   |
| pyproject.toml | pyproject.toml |   |   |
| run_tests.py | run_tests.py |   |   |
| run_tests_verbose.py | run_tests_verbose.py |   |   |
| test_config.json | test_config.json |   |   |
| uv.lock | uv.lock |   |   |
| View all files |

## Repository files navigation

# Pre-commit MCP Server

An MCP (Model Context Protocol) server that provides pre-commit integration for Claude instances.

## Features

- Run pre-commit on staged files with structured output
- Token-efficient output format for Claude processing
- Proper error handling and timeout management
- Git repository detection with override capability
- Support for all standard pre-commit hooks

## Installation

This project uses `uv` for package management:

```
uv sync
```

## Usage

The server provides a single tool: `pre_commit_run`

### Parameters

- `force_non_git` (bool, optional): Override git repository requirement. Default: False

### Output Format

The tool returns structured JSON with:

- `status`: "success" | "hooks_failed" | "system_error" | "timeout"
- `summary`: Hook execution statistics
- `failures`: Detailed failure information grouped by hook type
- `modified_files`: List of files modified by hooks
- `execution_time`: Total execution time in seconds

## Development

The project includes:

- Ruff for linting and formatting
- MyPy for type checking
- Pre-commit hooks for code quality

Run pre-commit to check code quality:

```
pre-commit run --all-files
```

## Configuration

The server respects the standard `.pre-commit-config.yaml` configuration file in the project root.

## About

        An MCP server that allows your LLM to issue pre-commit in the repo you are working in and process the results

### Resources

                              Readme

### Uh oh!

There was an error while loading. Please reload this page.

                          Activity

### Stars

                      **0**        stars

### Watchers

                      **0**        watching

### Forks

                      **1**        fork                        Report repository

## Releases

    No releases published

## Packages 0

              No packages published

## Languages

    -                                 Python          100.0%

## Footer

                                           © 2025 GitHub, Inc.                                                     You can’t perform that action at this time.

**Tool Call: Fetch https://raw.githubusercontent.com/sjswerdloff/pre\-commit\-mcp/main/README.md**
Status: Completed

# Pre-commit MCP Server

An MCP (Model Context Protocol) server that provides pre-commit integration for Claude instances.

## Features

- Run pre-commit on staged files with structured output
- Token-efficient output format for Claude processing
- Proper error handling and timeout management
- Git repository detection with override capability
- Support for all standard pre-commit hooks

## Installation

This project uses `uv` for package management:

```bash
uv sync
```

## Usage

The server provides a single tool: `pre_commit_run`

### Parameters

- `force_non_git` (bool, optional): Override git repository requirement. Default: False

### Output Format

The tool returns structured JSON with:

- `status`: "success" | "hooks_failed" | "system_error" | "timeout"
- `summary`: Hook execution statistics
- `failures`: Detailed failure information grouped by hook type
- `modified_files`: List of files modified by hooks
- `execution_time`: Total execution time in seconds

## Development

The project includes:

- Ruff for linting and formatting
- MyPy for type checking
- Pre-commit hooks for code quality

Run pre-commit to check code quality:

```bash
pre-commit run --all-files
```

## Configuration

The server respects the standard `.pre-commit-config.yaml` configuration file in the project root.

**Tool Call: Fetch https://raw.githubusercontent.com/sjswerdloff/pre\-commit\-mcp/main/pyproject.toml**
Status: Completed

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "pre-commit-mcp"
version = "0.1.0"
description = "MCP server for pre-commit integration with Claude"
authors = [{name = "Stuart Swerdloff", email = "sjswerdloff@gmail.com"}]
license = {text = "MIT"}
readme = "README.md"
requires-python = ">=3.12"
dependencies = [
"fastmcp>=0.1.0",
]

[project.optional-dependencies]
dev = [
"pytest",
"pytest-asyncio",
"mypy",
]

[tool.uv]
dev-dependencies = [
"pytest>=8.0.0",
"pytest-asyncio>=0.23.0",
"pytest-cov>=4.0.0",
"mypy>=1.8.0",
"pre-commit>=4.2.0",
]

[tool.ruff]
line-length = 127
target-version = "py312"

[tool.ruff.lint]
select = [
"E", # pycodestyle errors
"W", # pycodestyle warnings
"F", # pyflakes
"I", # isort
"B", # flake8-bugbear
"C4", # flake8-comprehensions
"UP", # pyupgrade
]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
skip-magic-trailing-comma = false
line-ending = "auto"

[tool.pytest.ini_options]
testpaths = ["tests"]
python*files = ["test*_.py"]
python_classes = ["Test_"]
python*functions = ["test*\*"]
addopts = [
"--cov=pre_commit_mcp",
"--cov-report=term-missing",
"--cov-report=html",
"--cov-fail-under=80",
]

[tool.mypy]
python_version = "3.12"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_incomplete_defs = true
check_untyped_defs = true
disallow_untyped_decorators = true
no_implicit_optional = true
warn_redundant_casts = true
warn_unused_ignores = true
warn_no_return = true
warn_unreachable = true
strict_equality = true

## Assistant

Now let me check how to configure it as an MCP server. Let me look for the actual server implementation:

**Tool Call: Run MCP tool `search`**
Status: Failed

Context server request timeout

## Assistant

Let me create a comprehensive installation guide based on the MCP server pattern:

**Tool Call: docs/internal/docs/map-tech/tools/just/sops/install-precommit-mcp.md**
Status: Completed

Diff: internal/docs/map-tech/tools/just/sops/install-precommit-mcp.md

````
# Installing pre-commit-mcp as an MCP Server

This guide explains how to install and configure the [pre-commit-mcp](https://github.com/sjswerdloff/pre-commit-mcp) server, which provides pre-commit integration for Claude and other AI assistants via the Model Context Protocol (MCP).

## Overview

The pre-commit-mcp server allows your AI assistant to:

- Run pre-commit hooks on staged files
- Get structured output about hook results
- Identify and fix code quality issues
- Process pre-commit failures efficiently

## Prerequisites

Before installing, ensure you have:

- **Python 3.12 or later**
- **uv** package manager (recommended) or **pip**
- **Git** installed and configured
- **pre-commit** installed in your projects
- **Claude Desktop** or another MCP-compatible client

## Installation Methods

### Method 1: Using uv (Recommended)

#### Step 1: Install uv

If you don't have uv installed:

```bash
# macOS/Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Or using Homebrew
brew install uv

# Windows (PowerShell)
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
````

#### Step 2: Clone the Repository

```bash
# Clone to a permanent location
cd ~/code/mcp-servers  # or your preferred directory
git clone https://github.com/sjswerdloff/pre-commit-mcp.git
cd pre-commit-mcp
```

#### Step 3: Install Dependencies

```bash
# Sync dependencies with uv
uv sync
```

This creates a virtual environment and installs all required dependencies.

#### Step 4: Locate the Python Executable

```bash
# Find the path to the virtual environment python
uv run which python
```

Note this path - you'll need it for the MCP configuration.

### Method 2: Using pip

#### Step 1: Clone the Repository

```bash
cd ~/code/mcp-servers
git clone https://github.com/sjswerdloff/pre-commit-mcp.git
cd pre-commit-mcp
```

#### Step 2: Create Virtual Environment

```bash
# Create virtual environment
python3 -m venv .venv

# Activate it
source .venv/bin/activate  # macOS/Linux
# or
.venv\Scripts\activate     # Windows
```

#### Step 3: Install Dependencies

```bash
pip install -e .
```

#### Step 4: Note the Python Path

```bash
which python  # macOS/Linux
where python  # Windows
```

## Configuration

### For Claude Desktop

Add the server to your Claude Desktop configuration file:

**macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`

**Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

**Linux**: `~/.config/Claude/claude_desktop_config.json`

#### Configuration Example (uv)

```json
{
  "mcpServers": {
    "pre-commit": {
      "command": "uv",
      "args": [
        "--directory",
        "/Users/username/code/mcp-servers/pre-commit-mcp",
        "run",
        "pre_commit_mcp"
      ]
    }
  }
}
```

Replace `/Users/username/code/mcp-servers/pre-commit-mcp` with your actual installation path.

#### Configuration Example (pip/venv)

```json
{
  "mcpServers": {
    "pre-commit": {
      "command": "/Users/username/code/mcp-servers/pre-commit-mcp/.venv/bin/python",
      "args": ["-m", "pre_commit_mcp"]
    }
  }
}
```

Replace the path with your actual virtual environment Python path.

### For Other MCP Clients

If using a different MCP client, configure it to run:

```bash
# Using uv
uv --directory /path/to/pre-commit-mcp run pre_commit_mcp

# Using venv
/path/to/pre-commit-mcp/.venv/bin/python -m pre_commit_mcp
```

## Verification

### Test the Installation

1. **Restart Claude Desktop** (or your MCP client)

2. **Verify the server is loaded**:
   - In Claude Desktop, check the settings or logs
   - Look for "pre-commit" in the available tools

3. **Test the tool**:
   Ask Claude: "Can you run pre-commit on my staged files?"

### Manual Testing

You can test the server manually:

```bash
# Using uv
cd ~/code/mcp-servers/pre-commit-mcp
uv run pre_commit_mcp

# Using venv
cd ~/code/mcp-servers/pre-commit-mcp
source .venv/bin/activate
python -m pre_commit_mcp
```

## Usage

Once installed, you can ask your AI assistant to:

### Run Pre-commit Checks

```
"Run pre-commit on my staged files"
"Check my code with pre-commit hooks"
"Run pre-commit and show me the results"
```

### Process Results

The server provides structured output including:

- **Status**: success, hooks_failed, system_error, or timeout
- **Summary**: Statistics about hook execution
- **Failures**: Detailed information about failed hooks
- **Modified Files**: Files changed by hooks
- **Execution Time**: How long it took to run

### Override Git Requirement

For non-Git repositories:

```
"Run pre-commit with force_non_git set to true"
```

## Troubleshooting

### Server Not Appearing

**Issue**: Pre-commit tool doesn't show up in Claude

**Solutions**:

1. **Check configuration file syntax**:

   ```bash
   # Validate JSON
   python -m json.tool ~/Library/Application\ Support/Claude/claude_desktop_config.json
   ```

2. **Verify paths are absolute**, not relative

3. **Restart Claude Desktop completely** (quit and reopen)

4. **Check Claude logs**:
   - macOS: `~/Library/Logs/Claude/`
   - Windows: `%APPDATA%\Claude\logs\`

### Permission Errors

**Issue**: Permission denied when running the server

**Solutions**:

```bash
# Ensure scripts are executable
chmod +x /path/to/pre-commit-mcp/.venv/bin/python

# Check ownership
ls -la /path/to/pre-commit-mcp
```

### Pre-commit Not Found

**Issue**: Server can't find pre-commit

**Solutions**:

1. **Install pre-commit in the project**:

   ```bash
   pip install pre-commit
   pre-commit install
   ```

2. **Ensure .pre-commit-config.yaml exists** in your project root

3. **Verify pre-commit is in PATH**:
   ```bash
   which pre-commit
   ```

### Python Version Issues

**Issue**: Wrong Python version

**Solutions**:

```bash
# Check Python version
python --version  # Should be 3.12+

# If using uv, specify Python version
uv python install 3.12
uv venv --python 3.12
```

### Server Crashes

**Issue**: Server starts but crashes during execution

**Solutions**:

1. **Check logs** in Claude Desktop logs directory

2. **Test manually**:

   ```bash
   cd /path/to/pre-commit-mcp
   uv run python -m pre_commit_mcp
   ```

3. **Verify dependencies**:
   ```bash
   uv sync
   # or
   pip install -e .
   ```

## Updates

### Updating the Server

```bash
cd ~/code/mcp-servers/pre-commit-mcp

# Pull latest changes
git pull

# Update dependencies
uv sync
# or
pip install -e .

# Restart Claude Desktop
```

## Integration with Projects

### Ensure Pre-commit is Configured

Your project needs a `.pre-commit-config.yaml` file:

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files

  - repo: https://github.com/psf/black
    rev: 23.12.1
    hooks:
      - id: black

  - repo: https://github.com/pycqa/flake8
    rev: 7.0.0
    hooks:
      - id: flake8
```

### Install Hooks

```bash
# In your project directory
pre-commit install
```

## Advanced Configuration

### Custom Working Directory

If you want the server to work in a specific directory:

```json
{
  "mcpServers": {
    "pre-commit": {
      "command": "uv",
      "args": [
        "--directory",
        "/path/to/pre-commit-mcp",
        "run",
        "pre_commit_mcp"
      ],
      "env": {
        "PWD": "/path/to/your/project"
      }
    }
  }
}
```

### Timeout Configuration

The server has built-in timeout handling. To adjust timeouts, you may need to modify the source code or wait for configuration options.

## Development

If you want to contribute or modify the server:

```bash
cd ~/code/mcp-servers/pre-commit-mcp

# Install development dependencies
uv sync --all-extras

# Run tests
uv run pytest

# Run pre-commit checks
uv run pre-commit run --all-files

# Type checking
uv run mypy pre_commit_mcp
```

## Uninstallation

To remove the pre-commit-mcp server:

1. **Remove from Claude config**:
   Edit `claude_desktop_config.json` and remove the "pre-commit" entry

2. **Delete the repository**:

   ```bash
   rm -rf ~/code/mcp-servers/pre-commit-mcp
   ```

3. **Restart Claude Desktop**

## See Also

- [MCP Documentation](https://modelcontextprotocol.io/)
- [Pre-commit Documentation](https://pre-commit.com/)
- [FastMCP Framework](https://github.com/jlowin/fastmcp)
- [Claude Desktop](https://claude.ai/download)

## Support

For issues with:

- **The MCP server**: [GitHub Issues](https://github.com/sjswerdloff/pre-commit-mcp/issues)
- **Pre-commit**: [Pre-commit Documentation](https://pre-commit.com/)
- **Claude Desktop**: [Anthropic Support](https://support.anthropic.com/)

```


## Assistant

Perfect! Now let me create a quick reference guide as well:

**Tool Call: `cat > INSTALL_PRECOMMIT_MCP.md << 'EOF' - 48 more lines`**
Status: Failed

`cd` directory "docs/internal" was not in any of the project's worktrees.

**Tool Call: `cat > internal/INSTALL_PRECOMMIT_MCP.md << 'EOF' - 48 more lines`**
Status: Completed

Terminal:
```

# Quick Install: pre-commit-mcp Server

## TL;DR

```bash
# 1. Install uv (if not already installed)
brew install uv

# 2. Clone and install
mkdir -p ~/code/mcp-servers
cd ~/code/mcp-servers
git clone https://github.com/sjswerdloff/pre-commit-mcp.git
cd pre-commit-mcp
uv sync

# 3. Configure Claude Desktop
# Edit: ~/Library/Application Support/Claude/claude_desktop_config.json
```

Add this to your Claude config:

```json
{
  "mcpServers": {
    "pre-commit": {
      "command": "uv",
      "args": [
        "--directory",
        "/Users/YOUR_USERNAME/code/mcp-servers/pre-commit-mcp",
        "run",
        "pre_commit_mcp"
      ]
    }
  }
}
```

Replace `YOUR_USERNAME` with your actual username.

## 4. Restart Claude Desktop

That's it! Now you can ask Claude to "run pre-commit on my staged files".

## Full Documentation

See [docs/map-tech/tools/just/sops/install-precommit-mcp.md](docs/map-tech/tools/just/sops/install-precommit-mcp.md) for complete details.

````


## Assistant

Perfect! Now let me create a summary document with the exact steps for your system:

## Installation Summary for pre-commit-mcp

I've created comprehensive installation documentation for the pre-commit-mcp server. Here's how to install it:

### 📋 Quick Installation Steps

#### 1. **Install uv Package Manager** (if not already installed)

```bash
brew install uv
````

#### 2. **Clone and Install the Server**

```bash
# Create directory for MCP servers
mkdir -p ~/code/mcp-servers
cd ~/code/mcp-servers

# Clone the repository
git clone https://github.com/sjswerdloff/pre-commit-mcp.git
cd pre-commit-mcp

# Install dependencies
uv sync
```

#### 3. **Configure Claude Desktop**

Edit your Claude Desktop configuration file:

```bash
# macOS location
nano ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

Add this configuration (replace `YOUR_USERNAME` with your actual username):

```json
{
  "mcpServers": {
    "pre-commit": {
      "command": "uv",
      "args": [
        "--directory",
        "/Users/YOUR_USERNAME/code/mcp-servers/pre-commit-mcp",
        "run",
        "pre_commit_mcp"
      ]
    }
  }
}
```

**Example for your system:**

```json
{
  "mcpServers": {
    "pre-commit": {
      "command": "uv",
      "args": [
        "--directory",
        "/Users/adamsm/code/mcp-servers/pre-commit-mcp",
        "run",
        "pre_commit_mcp"
      ]
    }
  }
}
```

#### 4. **Restart Claude Desktop**

Completely quit and restart Claude Desktop to load the new server.

### ✅ Verify Installation

After restarting Claude, you can test by asking:

- "Can you run pre-commit on my staged files?"
- "Run pre-commit and show me the results"

### 📚 Documentation Created

1. **Quick Reference**: `docs/internal/INSTALL_PRECOMMIT_MCP.md` - Quick start guide
2. **Complete Guide**: `docs/internal/docs/map-tech/tools/just/sops/install-precommit-mcp.md` - Full installation and troubleshooting guide

### 🔧 What This Server Does

The pre-commit-mcp server allows Claude to:

- Run pre-commit hooks on your staged files
- Get structured, token-efficient output about hook results
- Help identify and fix code quality issues
- Process pre-commit failures and suggest fixes

### 🛠️ Alternative Installation (Using pip)

If you prefer not to use `uv`:

```bash
cd ~/code/mcp-servers/pre-commit-mcp
python3 -m venv .venv
source .venv/bin/activate
pip install -e .
```

Then use this configuration:

```json
{
  "mcpServers": {
    "pre-commit": {
      "command": "/Users/adamsm/code/mcp-servers/pre-commit-mcp/.venv/bin/python",
      "args": ["-m", "pre_commit_mcp"]
    }
  }
}
```

### 📖 Full Documentation

For troubleshooting, advanced configuration, and development setup, see the complete guide in:
`docs/internal/docs/map-tech/tools/just/sops/install-precommit-mcp.md`
