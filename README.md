# prelint

Command-line interface for [Prelint](https://prelint.com).

Built for two audiences:
- **Humans** running `prelint statement search "..."` in a terminal.
- **AI agents** (Claude Code, Cursor, OpenClaw, custom subprocess invokers) calling the CLI to read and write the Prelint knowledge base on a developer's behalf.

## Install

### Homebrew (macOS, Linux)

```bash
brew install prelint/tap/prelint
```

### Shell one-liner (macOS, Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/prelint/cli/main/install.sh | sh
```

Pin a version or change the install directory:

```bash
PRELINT_VERSION=v0.1.0 \
  curl -fsSL https://raw.githubusercontent.com/prelint/cli/main/install.sh | sh
```

The default install directory is `~/.local/bin`. To install system-wide, set `PRELINT_INSTALL_DIR` and run with sudo:

```bash
curl -fsSL https://raw.githubusercontent.com/prelint/cli/main/install.sh \
  | sudo PRELINT_INSTALL_DIR=/usr/local/bin sh
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

## Authentication

```bash
prelint login    # opens your browser, authenticates with Prelint, stores a session token locally
prelint status   # show auth state
prelint logout   # clear tokens
```

Login uses OAuth 2.0 with PKCE via browser rendezvous — no local port binding, so it works in dev containers and NAT'd networks. The session token persists at `~/.config/prelint/`, so AI agents invoking `prelint` as a subprocess pick it up automatically after a one-time login.

## Usage

```bash
prelint init                       # pick a project for this repo
prelint statement list             # list statements in your knowledge base
prelint statement search "auth"    # semantic search
prelint ingest --text "..." --source "notes.md"
prelint doctor                     # diagnostic (JSON envelope)
```

Full command reference: [prelint.com/docs/cli](https://prelint.com/docs/cli).

## Issues and feature requests

Report issues at [github.com/prelint/cli/issues](https://github.com/prelint/cli/issues) or email support@prelint.com.

## License

The Prelint CLI is distributed as a closed-source binary. Use is governed by the [Prelint Terms of Service](https://prelint.com/terms).
