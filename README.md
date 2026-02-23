# iReminderCLI

A command-line interface for managing Apple Reminders on macOS.

## Features

- List all reminder lists.
- Show reminders from one list or all lists.
- Filter reminders by completion state and due date.
- Add reminders with natural-language due dates.
- Complete, uncomplete, edit, and delete reminders by index or ID.
- Create new reminder lists and choose account sources.
- Output JSON for scripting and automations.

## Installation

```bash
# Clone the repository
git clone https://github.com/VatsalSy/iReminderCLI.git
cd iReminderCLI

# Build + install (uses sudo automatically if needed)
./install.sh

# Optional: custom install location/name
./install.sh --install-dir "$HOME/.local/bin" --name ireminder
```

Manual workflow:

```bash
swift build -c release
sudo cp .build/release/iReminderCLI /usr/local/bin/ireminder
```

## Quick Start

```bash
# 1) See lists
ireminder show-lists

# 2) Add a reminder
ireminder add "Inbox" "Follow up with Alex" --due-date "tomorrow 10am"

# 3) Show reminders
ireminder show "Inbox"

# 4) Edit by index (from [0], [1], ...)
ireminder edit "Inbox" 0 --notes "Waiting on response"
```

## How `<identifier>` Works

Commands `complete`, `uncomplete`, `edit`, and `delete` take `<identifier>` as either:

1. `index` (0-based), from regular `show` output like `[0]`.
2. `id` (string), from JSON output field `id`.

Get IDs:

```bash
# Full JSON objects with id/title/etc.
ireminder show "Inbox" --json

# IDs only (if jq is installed)
ireminder show "Inbox" --json | jq -r '.[].id'
```

Notes:

- In current builds, IDs are typically UUID-like strings (for example `B66DE785-4276-44F5-B16E-680EE3F19915`).
- Quoting IDs is recommended in shell commands: `"<id>"`.
- Quoting list names is also recommended: `"Inbox"`, `"Work Tasks"`.

## Command Reference

### `show-lists`

Usage:

```bash
ireminder show-lists [--json]
```

Options:

- `-j, --json`: Output lists in JSON format.

Examples:

```bash
ireminder show-lists
ireminder show-lists --json
```

### `show`

Usage:

```bash
ireminder show <list-name> [--include-completed] [--only-completed] [--due-date <due-date>] [--json] [--sort-by <sort-by>]
```

Arguments:

- `<list-name>`: Reminder list name.

Options:

- `--include-completed`: Include completed reminders.
- `--only-completed`: Show only completed reminders.
- `--due-date <due-date>`: Filter by date (`today`, `tomorrow`, `2026-05-21`, etc.).
- `-j, --json`: Output reminders in JSON format.
- `--sort-by <sort-by>`: `due-date` (default) or `creation-date`.

Examples:

```bash
ireminder show "Inbox"
ireminder show "Inbox" --include-completed
ireminder show "Inbox" --only-completed
ireminder show "Inbox" --due-date today
ireminder show "Inbox" --sort-by creation-date
ireminder show "Inbox" --json
```

### `show-all`

Usage:

```bash
ireminder show-all [--include-completed] [--only-completed] [--due-date <due-date>] [--json] [--sort-by <sort-by>]
```

Options:

- `--include-completed`: Include completed reminders.
- `--only-completed`: Show only completed reminders.
- `--due-date <due-date>`: Filter by date.
- `-j, --json`: Output reminders in JSON format.
- `--sort-by <sort-by>`: `due-date` (default) or `creation-date`.

Examples:

```bash
ireminder show-all
ireminder show-all --include-completed
ireminder show-all --due-date tomorrow
ireminder show-all --json
```

### `add`

Usage:

```bash
ireminder add <list-name> <text> [--due-date <due-date>] [--priority <priority>] [--notes <notes>]
```

Arguments:

- `<list-name>`: Reminder list name.
- `<text>`: Reminder title.

Options:

- `--due-date <due-date>`: Natural-language due date.
- `--priority <priority>`: Priority `0-3` (`3` highest, default `0`).
- `--notes <notes>`: Reminder notes.

Examples:

```bash
ireminder add "Inbox" "Follow up with finance"
ireminder add "Work" "Finish quarterly report" --due-date "Friday 5pm"
ireminder add "Work" "Incident review" --priority 3 --notes "Bring metrics"
```

### `complete`

Usage:

```bash
ireminder complete <list-name> <identifier>
```

Arguments:

- `<list-name>`: Reminder list name.
- `<identifier>`: 0-based index or reminder ID string.

Examples:

```bash
ireminder complete "Inbox" 0
ireminder complete "Inbox" "B66DE785-4276-44F5-B16E-680EE3F19915"
```

### `uncomplete`

Usage:

```bash
ireminder uncomplete <list-name> <identifier>
```

Arguments:

- `<list-name>`: Reminder list name.
- `<identifier>`: 0-based index or reminder ID string.

Examples:

```bash
ireminder uncomplete "Inbox" 0
ireminder uncomplete "Inbox" "B66DE785-4276-44F5-B16E-680EE3F19915"
```

### `edit`

Usage:

```bash
ireminder edit <list-name> <identifier> [<text>] [--notes <notes>] [--due-date <due-date>] [--clear-due-date]
```

Arguments:

- `<list-name>`: Reminder list name.
- `<identifier>`: 0-based index or reminder ID string.
- `<text>`: Optional new title.

Options:

- `--notes <notes>`: Set/update notes.
- `--due-date <due-date>`: Set/update due date.
- `--clear-due-date`: Clear due date and associated alarms.

Behavior rules:

- Provide at least one of `<text>`, `--notes`, `--due-date`, `--clear-due-date`.
- `--due-date` and `--clear-due-date` cannot be used together.

Examples:

```bash
ireminder edit "Inbox" 0 "Updated title"
ireminder edit "Inbox" 0 --notes "Need manager sign-off"
ireminder edit "Inbox" 0 --due-date "tomorrow 3pm"
ireminder edit "Inbox" "B66DE785-4276-44F5-B16E-680EE3F19915" --clear-due-date
ireminder edit "Inbox" 0 "Updated title" --notes "Need manager sign-off" --due-date "Friday 5pm"
```

### `delete`

Usage:

```bash
ireminder delete <list-name> <identifier> [--include-completed]
```

Arguments:

- `<list-name>`: Reminder list name.
- `<identifier>`: 0-based index or reminder ID string.

Options:

- `--include-completed`: Include completed reminders when resolving index.

Examples:

```bash
ireminder delete "Inbox" 0
ireminder delete "Inbox" "B66DE785-4276-44F5-B16E-680EE3F19915"
ireminder delete "Inbox" 0 --include-completed
```

### `new-list`

Usage:

```bash
ireminder new-list <name> [--source <source>]
```

Arguments:

- `<name>`: New list name.

Options:

- `--source <source>`: Account/source title (`iCloud`, `Local`, etc.).

Examples:

```bash
ireminder new-list "Groceries"
ireminder new-list "Work Tasks" --source "iCloud"
```

## Date Input Examples

Natural-language parsing supports inputs like:

- `today`
- `tomorrow`
- `tomorrow 3pm`
- `next Monday`
- `Friday at 5pm`
- `in 2 hours`
- `in 3 days`
- `2026-05-21`
- `May 21 2026 18:00`

## Permissions and Troubleshooting

On first run, macOS asks for Reminders access for your terminal app.

If you see access denied:

```bash
tccutil reset Reminders
```

Then rerun `ireminder` and accept the permission prompt.

## Requirements

- macOS 13.0 or later.
- Swift 6.1 or later.
- Reminders permission granted to your terminal app.

## Security & Privacy

- Local-only operation.
- No network calls for reminder operations.
- No analytics or telemetry collection.
- Uses Apple's EventKit APIs.

## Building and Testing

```bash
# Build debug
swift build

# Build release
swift build -c release

# Run tests
swift test
```

## License

MIT License. See `LICENSE`.
