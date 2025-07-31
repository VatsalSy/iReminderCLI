# iReminderCLI

A command-line interface for managing Apple Reminders on macOS.

## Features

- List all reminder lists
- Show reminders with filtering options
- Add new reminders with natural language dates
- Mark reminders as complete/incomplete
- Edit existing reminders
- Delete reminders
- Create new reminder lists
- JSON output support for scripting

## Installation

```bash
# Clone the repository
git clone https://github.com/VatsalSy/iReminderCLI.git
cd iReminderCLI

# Build the project
swift build -c release

# Copy to your PATH
cp .build/release/iReminderCLI /usr/local/bin/ireminder
```

## Usage

### Show all reminder lists
```bash
ireminder show-lists
ireminder show-lists --json
```

### Show reminders in a list
```bash
# Show incomplete reminders
ireminder show "Shopping"

# Include completed reminders
ireminder show "Shopping" --include-completed

# Show only completed reminders
ireminder show "Shopping" --only-completed

# Filter by due date
ireminder show "Shopping" --due-date today
ireminder show "Shopping" --due-date tomorrow

# Sort by creation date instead of due date
ireminder show "Shopping" --sort-by creation-date

# JSON output
ireminder show "Shopping" --json
```

### Show reminders from all lists
```bash
ireminder show-all
ireminder show-all --due-date today
ireminder show-all --include-completed
```

### Add a new reminder
```bash
# Basic reminder
ireminder add "Shopping" "Buy milk"

# With due date (natural language supported)
ireminder add "Shopping" "Buy milk" --due-date "tomorrow 3pm"
ireminder add "Work" "Finish report" --due-date "next Monday"
ireminder add "Personal" "Call mom" --due-date "in 2 hours"

# With priority (0-3, where 3 is highest)
ireminder add "Work" "Important meeting" --priority 3

# With notes
ireminder add "Shopping" "Buy groceries" --notes "Don't forget organic vegetables"

# All options combined
ireminder add "Work" "Project deadline" --due-date "Friday 5pm" --priority 3 --notes "Final review needed"
```

### Complete/Uncomplete reminders
```bash
# Complete by index (0-based)
ireminder complete "Shopping" 0

# Complete by ID
ireminder complete "Shopping" "x-apple-reminder://ABCD1234"

# Mark as incomplete
ireminder uncomplete "Shopping" 0
```

### Edit reminders
```bash
# Edit title
ireminder edit "Shopping" 0 "Buy organic milk"

# Edit notes
ireminder edit "Shopping" 0 --notes "Check for 2% milk"

# Edit both
ireminder edit "Shopping" 0 "Buy milk and eggs" --notes "From farmer's market"
```

### Delete reminders
```bash
# Delete by index
ireminder delete "Shopping" 0

# Delete by ID
ireminder delete "Shopping" "x-apple-reminder://ABCD1234"

# Include completed reminders when searching by index
ireminder delete "Shopping" 0 --include-completed
```

### Create a new list
```bash
# Create in default account
ireminder new-list "Groceries"

# Create in specific account
ireminder new-list "Work Tasks" --source "iCloud"
```

## Natural Language Date Examples

The tool supports various natural language date formats:

- `today`
- `tomorrow`
- `tomorrow 3pm`
- `next Monday`
- `Friday at 5pm`
- `in 2 hours`
- `in 3 days`
- `2024-12-25`
- `December 25th at 3:30pm`

## Requirements

- macOS 13.0 or later
- Swift 6.1 or later
- Reminders access permission (will be requested on first run)

## Privacy

This tool requires access to your Reminders data. On first run, macOS will prompt you to grant access. The tool only accesses Reminders data locally and does not send any data over the network.

## Building from Source

```bash
# Clone the repository
git clone https://github.com/VatsalSy/iReminderCLI.git
cd iReminderCLI

# Build debug version
swift build

# Build release version
swift build -c release

# Run tests
swift test
```

## License

MIT License - see LICENSE file for details.