---
name: release-ireminder
description: Create versioned releases with proper `vMAJOR.MINOR.PATCH` tags for iReminderCLI and keep GitHub release/tag version aligned with the CLI version. Use when asked to "release", "cut a release", "bump version", "create tag", "publish", or prepare the next iReminder version.
---

# Release Workflow (Local, after merge, before tag)

`Sources/iReminderCLI/iReminderCLI.swift` is the version source of truth (`version: "X.Y.Z"`).  
GitHub tag and release must use `vX.Y.Z` and match the same CLI version.

## Pre-flight Checks

```bash
git branch --show-current  # Must be "main"
git status --porcelain     # Must be empty
git fetch origin main && git diff HEAD origin/main --quiet
```

## Analyze Changes Since Last Tag

```bash
LAST_TAG=$(git describe --tags --abbrev=0)
echo "$LAST_TAG"  # Currently expected to be v1.0.0 unless a newer release exists
git log "$LAST_TAG"..HEAD --oneline

CURRENT=$(python3 - <<'PY'
import pathlib, re
text = pathlib.Path("Sources/iReminderCLI/iReminderCLI.swift").read_text()
m = re.search(r'version:\s*"(\d+\.\d+\.\d+)"', text)
if not m:
    raise SystemExit("Could not find CLI version in Sources/iReminderCLI/iReminderCLI.swift")
print(m.group(1))
PY
)
echo "$CURRENT"
```

## Decide Bump and Tag

| Change Type | Bump | Example |
| --- | --- | --- |
| Breaking changes | `major` | 1.0.0 -> 2.0.0 |
| New features | `minor` | 1.0.0 -> 1.1.0 |
| Fixes/docs/refactors | `patch` | 1.0.0 -> 1.0.1 |

```bash
BUMP=<patch|minor|major>
CURRENT=$(python3 - <<'PY'
import pathlib, re
text = pathlib.Path("Sources/iReminderCLI/iReminderCLI.swift").read_text()
m = re.search(r'version:\s*"(\d+\.\d+\.\d+)"', text)
if not m:
    raise SystemExit("Could not find CLI version in Sources/iReminderCLI/iReminderCLI.swift")
print(m.group(1))
PY
)
NEXT=$(python3 - "$CURRENT" "$BUMP" <<'PY'
import sys
current, bump = sys.argv[1], sys.argv[2]
parts = current.split(".")
if len(parts) != 3:
    raise SystemExit("Current version must be MAJOR.MINOR.PATCH")
maj, min_, pat = map(int, parts)
if bump == "major":
    maj += 1
    min_ = 0
    pat = 0
elif bump == "minor":
    min_ += 1
    pat = 0
elif bump == "patch":
    pat += 1
else:
    raise SystemExit("BUMP must be one of: patch, minor, major")
print(f"{maj}.{min_}.{pat}")
PY
)
TAG="v$NEXT"
```

## Bump CLI Version Locally

```bash
python3 - "$NEXT" <<'PY'
import pathlib, re, sys
next_version = sys.argv[1]
path = pathlib.Path("Sources/iReminderCLI/iReminderCLI.swift")
text = path.read_text()
new, count = re.subn(r'(version:\s*")\d+\.\d+\.\d+(")', rf'\g<1>{next_version}\2', text, count=1)
if count != 1:
    raise SystemExit("Failed to update CLI version in Sources/iReminderCLI/iReminderCLI.swift")
path.write_text(new)
print(f"Updated CLI version to {next_version}")
PY

VERSION=$(python3 - <<'PY'
import pathlib, re
text = pathlib.Path("Sources/iReminderCLI/iReminderCLI.swift").read_text()
m = re.search(r'version:\s*"(\d+\.\d+\.\d+)"', text)
if not m:
    raise SystemExit("Could not find CLI version in Sources/iReminderCLI/iReminderCLI.swift")
print(m.group(1))
PY
)
test "$VERSION" = "$NEXT"
```

## Build and Validate

```bash
swift build -c release
swift test
.build/release/iReminderCLI --version
```

Confirm `.build/release/iReminderCLI --version` prints the same `VERSION`.

## Commit, Tag, Push

```bash
git add Sources/iReminderCLI/iReminderCLI.swift
git commit -m "Release v$VERSION"
git tag -a "v$VERSION" -m "Release v$VERSION"
git push origin main --follow-tags
```

## Publish GitHub Release (match CLI version)

If release automation exists, verify it triggers on `v*.*.*` tags.  
If no automation exists, publish manually:

```bash
gh release create "v$VERSION" --title "v$VERSION" --generate-notes
```

## Post-release Verification

Confirm all versions match exactly:

- Git tag: `v$VERSION`
- GitHub release: `v$VERSION`
- CLI reported version: `ireminder --version` (or `.build/release/iReminderCLI --version`) -> `$VERSION`

## Rollback (if needed)

```bash
git tag -d vX.Y.Z
git push origin --delete vX.Y.Z
git revert <release-commit-sha>
git push origin main
```
