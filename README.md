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

A set version also turns off automatic updates, so that version stays installed.

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

The CLI updates itself. Once a day, when you run a command, it asks github.com for the latest `prelint/cli` release. The request runs in the background and carries only the CLI version. When a newer release exists, the same background process installs it. The command you ran does not wait. The new version runs from your next command, and on a terminal it prints what changed. To read the notes again, run `prelint changelog`.

A Homebrew install updates itself only when you allow it. `prelint init` asks once on a terminal. If you say yes, the background process runs `brew upgrade prelint`. If you say no, the CLI prints a notice once a day. To change the answer, run `prelint config set homebrew_auto_update true` or `false`. `PRELINT_HOMEBREW_AUTO_UPDATE=1` turns it on for one shell.

To update now:

```bash
prelint update
```

On a Homebrew install, it runs `brew upgrade prelint`. Homebrew checks the download against the SHA256 in the formula that each release publishes to `prelint/homebrew-tap`. On other installs, it checks the download against the `SHA256SUMS` file of the same release. This catches a corrupt download. It does not protect against a compromised release, because both files come from the same place.

If an automatic update fails, for example because the install folder needs root, the CLI prints the error with the available-version notice. `prelint doctor` shows it in `update_error`. To turn off automatic updates on a direct install, run `prelint config set auto_update false`. `PRELINT_NO_AUTO_UPDATE=1` turns them off on every install. To turn off the check too, set `PRELINT_NO_UPDATE_CHECK=1`.

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

`prelint init` puts the repository in a project, writes `prelint.json` at the repository root, offers to turn on documents and reviews, adds the `prelint-setup` skill for your coding agent, and prints what is left to do. A `prelint.json` the server would reject does not stop it. The checklist names the problem, and the skill fixes it. A project set in the dashboard wins, so the file follows it. No command reads `.prelint.json`. If a checkout holds only that file, run `prelint init`. `init` exits 0 after the write. A `--run-skill` run that does not finish exits 9. Run `prelint doctor --repo` to print the checklist again. It exits 8 while an item is left, so a script under `set -e` allows that with `|| [ $? -eq 8 ]`. Documents that are off count as an item (`documents_disabled`), so a repository that uses reviews only also exits 8. It also shows whether your documents became knowledge, and why not when they did not.

## Usage

```bash
prelint init                       # write prelint.json, print the setup checklist
prelint statement list             # list statements in your knowledge base
prelint statement search "auth"    # semantic search
prelint ingest --text "..." --source "notes.md"
prelint doctor                     # diagnostic (JSON envelope)
prelint init --run-skill           # also run the skill in Claude Code or Codex, with no question
prelint init --run-skill=codex     # name the agent that runs it
prelint init --enable-documents    # turn on documents with no question (--enable-reviews for reviews)
prelint skill install              # add the prelint-setup skill by hand, or again after an upgrade
```

`prelint init` adds a skill your coding agent (Claude Code, Codex, Cursor, and others) runs to decide which markdown Prelint should ingest and which it should ignore. The skill writes the result into `prelint.json`. `init` adds it when the repository holds agent files, unless you pass `--no-skill`. When `claude` or `codex` is on your `PATH`, `init` offers to run the skill at once. That run asks nothing. A file the skill is not sure about stays in, and `init` lists those files at the end with the command that clears the doubts in your agent. `--run-skill` skips the question. `--run-skill=claude` or `--run-skill=codex` names the agent. In Claude Code the run can write `prelint.json` only. In Codex the run uses the workspace sandbox, which can change other files and commit. The question says so, and Enter means no. Check `git status` before you commit. If the run made a commit or staged a file, `init` says so. `prelint skill install` adds the skill anywhere, and `--claude` adds the copy Claude Code reads.

Full command reference: [prelint.com/docs/cli](https://prelint.com/docs/cli).

## Issues and feature requests

Report issues at [github.com/prelint/cli/issues](https://github.com/prelint/cli/issues).

## License

The Prelint CLI is distributed as a closed-source binary. Use is governed by the [Prelint Terms of Service](https://prelint.com/terms).
