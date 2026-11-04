# Changelog

Changes to the `prelint` CLI that a user, a script, or an agent can see. Newest first.

## Unreleased

## 0.2.0 (2026-11-04)

### Added

- `prelint.json` accepts `include_authors`, `exclude_authors`, and `trigger_mode`. `init` and `doctor --repo` check them with the server rules.
- `init` asks to turn on documents and reviews. Enter means yes. `--enable-documents` and `--enable-reviews` skip the questions.
- `doctor --repo` shows whether the documents became knowledge: the last scan, the status of each file, and the statement counts. With no accepted statement, `knowledge.reason` says why and `knowledge.wait` says if waiting helps.
- `statement list --repository-id` lists the statements from one repository.
- The daily update check installs a newer release in the background. The next run on a terminal prints what changed. `prelint config set auto_update false` or `PRELINT_NO_AUTO_UPDATE=1` turns this off.
- `install.sh` with `PRELINT_VERSION` turns off automatic updates, so that version stays installed.
- A Homebrew install updates in the background only when allowed. `init` asks once. The answer goes to the `homebrew_auto_update` config key.
- `update` on Homebrew reports `not_yet` when the tap does not have the newest release yet.
- `prelint changelog` prints the release notes built into the CLI. `--version` shows one release.
- `doctor` shows `auto_update`, `auto_update_source`, `auto_update_hint`, and `update_error`.

### Changed

- `init` does not stop at an invalid `prelint.json`. It finishes the setup and shows each problem as a `local_*` checklist item.
- A switch error does not stop `init`. It shows as a `*_enable_refused` or `*_enable_failed` item.
- `doctor --repo` exits 8 while a `local_*` item or `documents_disabled` is left.
- If a server call fails, `init` and `doctor --repo` show the local items first, then exit with the error code.
- The setup skill fixes an invalid `prelint.json` first and lists it under `Doubts:`. It does not change the author lists or the trigger mode. An installed copy stays until `prelint skill install --replace`.
- A `--run-skill` run that leaves a `local_*` item exits 9.
- On a Homebrew install, `update` runs `brew upgrade prelint` instead of printing it.

### Security

- The CLI no longer trusts a certificate authority whose keys leaked. Update with `prelint update` or `brew upgrade prelint`.

## 0.1.0 (2026-10-21)

### Added

- `init` sets up a repository. It puts the repository in a project, writes `prelint.json` at the checkout root, and prints a setup checklist.
- `doctor --repo` prints the checklist without a write. Exit 8 means an item is left.
- `init` installs the `prelint-setup` agent skill and can run it in Claude Code or Codex (`--run-skill`). Exit 9 means the run did not finish. Codex can change other files and commit, and `init` reports it. `skill install` installs the skill alone.
- `update` installs the newest release. A Homebrew install prints `brew upgrade prelint` instead. A daily notice on a terminal says when one exists. `PRELINT_NO_UPDATE_CHECK` or `CI` turns it off.
- `statement confirm`, `statement provenance`, `statement location`, `ingestions delete`, `contradictions resolve`, `glossary events`, and `topic events`.
- `--page` and `--page-size` on every paginated list.
- Install with `brew install prelint/tap/prelint` or `curl -fsSL https://install.prelint.com | sh`.

### Changed

- Breaking: commands read `prelint.json` at the checkout root, not `.prelint.json`. Run `prelint init` to create the new file.
- `login` shows its version and environment, and its progress while it waits.

## 0.1.0-rc1 (2026-05-19)

First release.

- Browser login, or `PRELINT_API_TOKEN` without a browser.
- `init`, `project list`, `statement`, `ingest`, `ingestions`, `topic list`, `glossary list`, `contradictions list`, and `doctor`.
- JSON output with `schema_version` "1".
- Exit codes 0 to 7.
