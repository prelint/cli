# prelint

Command-line interface for [Prelint](https://prelint.com).

Built for humans and CI. Developers run `prelint statement search "..."` in a terminal. Pipelines run the same binary.

Coding agents do not need this binary. The hosted MCP server at `https://app.prelint.com/mcp` gives an MCP client the same knowledge-base actions:

```bash
claude mcp add --transport http prelint https://app.prelint.com/mcp
```

## Install

### Homebrew (macOS, Linux)

```bash
brew install prelint/tap/prelint
```

### Shell one-liner (macOS, Linux)

```bash
curl -fsSL https://install.prelint.com | sh
```

Pin a version or change the install directory:

```bash
curl -fsSL https://install.prelint.com | PRELINT_VERSION=v0.1.0 sh
```

The default install directory is `~/.local/bin`. To install system-wide, set `PRELINT_INSTALL_DIR` and run with sudo:

```bash
curl -fsSL https://install.prelint.com | sudo PRELINT_INSTALL_DIR=/usr/local/bin sh
```

### Manual download

Binaries and a `SHA256SUMS` file are attached to each [release](https://github.com/prelint/cli/releases). Verify the SHA256 before running:

```bash
shasum -a 256 -c SHA256SUMS --ignore-missing
chmod +x prelint-macos-arm64
mv prelint-macos-arm64 ~/.local/bin/prelint
```

### Supported platforms

| Platform | Asset name |
|----------|------------|
| macOS (Apple Silicon) | `prelint-macos-arm64` |
| macOS (Intel) | `prelint-macos-x86_64` |
| Linux (x86_64, musl) | `prelint-linux-x86_64-musl` |
| Windows (x86_64) | `prelint-windows-x86_64.exe` |

Windows install via package manager is not yet wired up. Download the `.exe` from the latest release and place it on your PATH.

## Update

```bash
prelint update
```

A Homebrew install prints `brew upgrade prelint` instead.

`prelint update` checks the download against the `SHA256SUMS` file of the same release. This catches a corrupt download. It does not protect against a compromised release, because both files come from the same place.

Once a day, when you run a command, the CLI asks github.com for the latest `prelint/cli` release. The request runs in the background and carries only the CLI version. When a newer release exists, the CLI prints a one-line notice on a terminal, and `prelint doctor` shows it. To turn the check off, set `PRELINT_NO_UPDATE_CHECK=1`.

## Authentication

```bash
prelint login    # opens your browser, authenticates with Prelint, stores a session token locally
prelint status   # show auth state
prelint logout   # clear tokens
```

Login uses OAuth 2.0 with PKCE via browser rendezvous (no local port binding), so it works in dev containers and NAT'd networks. The session token persists at `~/.config/prelint/`, so a subprocess invoker picks it up automatically after a one-time login.

## Set up a repository

```bash
curl -fsSL https://install.prelint.com | sh && prelint login && prelint init
```

`prelint init` puts the repository in a project, writes `prelint.json` at the repository root, adds the `prelint-setup` skill for your coding agent, and prints what is left to do. A project set in the dashboard wins, so the file follows it. No command reads `.prelint.json`. If a checkout holds only that file, run `prelint init`. `init` exits 0 after the write. A `--run-skill` run that does not finish exits 9. Run `prelint doctor --repo` to print the checklist again. It exits 8 while an item is left, so a script under `set -e` allows that with `|| [ $? -eq 8 ]`.

## Usage

```bash
prelint init                       # write prelint.json, print the setup checklist
prelint statement list             # list statements in your knowledge base
prelint statement search "auth"    # semantic search
prelint ingest --text "..." --source "notes.md"
prelint doctor                     # diagnostic (JSON envelope)
prelint init --run-skill           # also run the skill in Claude Code or Codex, with no question
prelint init --run-skill=codex     # name the agent that runs it
prelint skill install              # add the prelint-setup skill by hand, or again after an upgrade
```

`prelint init` adds a skill your coding agent (Claude Code, Codex, Cursor, and others) runs to decide which markdown Prelint should ingest and which it should ignore. The skill writes the result into `prelint.json`. `init` adds it when the repository holds agent files, unless you pass `--no-skill`. When `claude` or `codex` is on your `PATH`, `init` offers to run the skill at once. That run asks nothing. A file the skill is not sure about stays in, and `init` lists those files at the end with the command that clears the doubts in your agent. `--run-skill` skips the question. `--run-skill=claude` or `--run-skill=codex` names the agent. In Claude Code the run can write `prelint.json` only. In Codex the run uses the workspace sandbox, which can change other files and commit. The question says so, and Enter means no. Check `git status` before you commit. If the run made a commit or staged a file, `init` says so. `prelint skill install` adds the skill anywhere, and `--claude` adds the copy Claude Code reads.

Full command reference: [prelint.com/docs/cli](https://prelint.com/docs/cli).

## Issues and feature requests

Report issues at [github.com/prelint/cli/issues](https://github.com/prelint/cli/issues).

## License

The Prelint CLI is distributed as a closed-source binary. Use is governed by the [Prelint Terms of Service](https://prelint.com/terms).
